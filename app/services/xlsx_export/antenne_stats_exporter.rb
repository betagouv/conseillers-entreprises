module XlsxExport
  class AntenneStatsExporter < BaseExporter
    def initialize(params)
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @antenne = params[:antenne]
    end

    def xlsx
      p = Axlsx::Package.new
      wb = p.workbook

      @title = wb.styles.add_style bg_color: 'DD', sz: 16, b: true, alignment: { horizontal: :center, vertical: :center }

      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{@end_date.year}T#{TimeDurationService.find_quarter(@start_date.month)}"], style: @title
        AntenneStatWorksheetGenerator.new(sheet, @antenne, @start_date, @end_date, wb.styles).generate
      end

      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.year_stats')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: @title
        year_start_date = @start_date.beginning_of_year
        AntenneStatWorksheetGenerator.new(sheet, @antenne, year_start_date, @end_date, wb.styles).generate
      end

      p.use_shared_strings = true
      p
    end
  end

  class AntenneStatWorksheetGenerator
    def initialize(sheet, antenne, start_date, end_date, styles)
      @antenne = antenne
      @sheet = sheet
      @start_date = start_date
      @end_date = end_date
      create_styles styles
    end

    def generate
      generate_base_stats
      generate_matches_stats
      generate_needs_stats
      finalise_style
    end

    def generate_base_stats
      sheet.add_row [I18n.t('antenne_stats_exporter.subtitle')], style: @subtitle
      sheet.add_row

      sheet.add_row [I18n.t('antenne_stats_exporter.needs'), needs.size], style: [@bold, nil]
      sheet.add_row [I18n.t('antenne_stats_exporter.matches'), matches.size], style: [@bold, nil]
      sheet.add_row [I18n.t('antenne_stats_exporter.facilities'), facilities.size], style: [@bold, nil]
      sheet.add_row
    end

    def generate_matches_stats
      ordered_match_statuses = [:done_not_reachable, :done, :done_no_help, :not_for_me, :quo, :taking_care]
      ordered_positionning_statuses = [:positionning, :positionning_accepted, :done, :not_for_me, :quo, nil]

      sheet.add_row [
        I18n.t('attributes.match_status'),
        I18n.t('antenne_stats_exporter.count'),
        I18n.t('antenne_stats_exporter.percentage'),nil,
        I18n.t('antenne_stats_exporter.answer_rate'),
        I18n.t('antenne_stats_exporter.count'),
        I18n.t('antenne_stats_exporter.percentage')
      ], style: [@left_header, @right_header, @right_header, nil, @left_header, @right_header, @right_header]

      (0...ordered_match_statuses.size).to_a.each do |index|
        match_status = ordered_match_statuses[index]
        match_status_size = matches.send("status_#{match_status}")&.size
        positionning_status = ordered_positionning_statuses[index]
        positionning_status_size = calculate_positionning_status_size(positionning_status)
        sheet.add_row [
          I18n.t("activerecord.attributes.match/statuses/short.#{match_status}"),
          match_status_size,
          match_rate(match_status_size), nil,
          positionning_status.present? ? I18n.t("antenne_stats_exporter.#{positionning_status}_rate") : nil,
          positionning_status_size,
          match_rate(positionning_status_size)
        ], style: count_rate_row_style
      end
      sheet.add_row
    end

    def generate_needs_stats
      ordered_need_statuses = [:done, :done_no_help, :done_not_reachable, :quo, :not_for_me, :taking_care]
      # On ne prend que les thèmes principaux
      themes = Theme.for_interview.limit(10)

      sheet.add_row [
        I18n.t('attributes.need_status'),
        I18n.t('antenne_stats_exporter.count'),
        I18n.t('antenne_stats_exporter.percentage'),nil,
        Theme.model_name.human,
        I18n.t('antenne_stats_exporter.count'),
        I18n.t('antenne_stats_exporter.percentage')
      ], style: [@left_header, @right_header, @right_header, nil, @left_header, @right_header, @right_header]

      (0...themes.size).to_a.each do |index|
        need_status = ordered_need_statuses[index]
        need_status_size = needs.send("status_#{need_status}")&.size if need_status.present?
        theme = Theme.find_by(interview_sort_order: index + 1)
        needs_by_theme_size = calculate_needs_by_theme_size(theme)
        sheet.add_row [
          need_status.present? ? I18n.t("activerecord.attributes.need/statuses/csv.#{need_status}") : nil,
          need_status_size || nil,
          need_rate(need_status_size), nil,
          theme&.label,
          needs_by_theme_size,
          need_rate(needs_by_theme_size)
        ], style: count_rate_row_style
      end
      sheet.add_row
    end

    def finalise_style
      [
        'A1:G1',
        'A2:G2',
      ].each { |range| sheet.merge_cells(range) }

      sheet.column_widths 50, 8, 8, 2, 50, 8, 8
    end

    # Base variables
    #
    def sheet
      @sheet
    end

    def needs
      @needs ||= @antenne.received_needs.joins(:matches).created_between(@start_date, @end_date).distinct
    end

    def matches
      @matches ||= @antenne.received_matches.where(need_id: needs.pluck(:id)).distinct
    end

    def facilities
      @facilities ||= @antenne.received_facilities.joins(diagnoses: :needs).where(diagnoses: { needs: needs }).distinct
    end

    # Calculation
    #
    def match_rate(status_size)
      return unless status_size
      status_size / matches.size.to_f
    end

    def need_rate(status_size)
      return unless status_size
      status_size / needs.size.to_f
    end

    def calculate_positionning_status_size(status)
      return unless status
      case status
      # Pris en charge, refusé, clôturé avec aide, clôturé sans aide, injoignable
      when :positionning
        matches.size - matches.status_quo.size
      # Pris en charge, clôturé avec aide, clôturé sans aide, injoignable
      when :positionning_accepted
        matches.size - (matches.status_quo.size + matches.status_not_for_me.size)
      else
        matches.send("status_#{status}")&.size
      end
    end

    def calculate_needs_by_theme_size(theme)
      needs.joins(subject: :theme).where(subject: { theme: theme }).size
    end

    # Style
    #
    def create_styles(s)
      @subtitle     = s.add_style bg_color: 'DD', sz: 14, b: true, alignment: { horizontal: :center, vertical: :center }
      @bold         = s.add_style b: true
      @left_header  = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :left }
      @right_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :right }
      @label = s.add_style alignment: { indent: 1 }
      @rate = s.add_style format_code: '#0.0%'
      s
    end

    def count_rate_row_style
      [@label, nil, @rate, nil, @label, nil, @rate]
    end
  end
end
