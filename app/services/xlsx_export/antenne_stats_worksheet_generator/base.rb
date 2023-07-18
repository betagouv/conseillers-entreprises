module XlsxExport
  module AntenneStatsWorksheetGenerator
    class Base
      def initialize(sheet, antenne, needs, styles)
        @antenne = antenne
        @needs = needs
        @sheet = sheet
        create_styles styles
      end

      def generate
        generate_base_stats
        generate_matches_stats
        generate_needs_stats
        generate_themes_stats
        finalise_style
      end

      def generate_base_stats
        sheet.add_row [I18n.t('antenne_stats_exporter.subtitle')], style: @subtitle
        sheet.add_row

        sheet.add_row [I18n.t('antenne_stats_exporter.needs'), @needs.size], style: [@bold, nil]
        sheet.add_row [I18n.t('antenne_stats_exporter.facilities'), facilities.size], style: [@bold, nil]
        sheet.add_row
      end

      def generate_themes_stats
        # On ne prend que les thèmes principaux
        themes = Theme.for_interview.limit(10)
        needs_subject_ids = @needs.pluck(:subject_id).uniq
        # On ne répertorie que les sujets pour lesquels on a un besoin référencé
        subjects = Subject.where(theme_id: themes.pluck(:id)).where(id: needs_subject_ids)
        max_length = [themes.size, subjects.size].max

        sheet.add_row [
          Theme.model_name.human,
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage'), nil,
          Subject.model_name.human,
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage'),
        ], style: count_rate_header_style

        (0...max_length).to_a.each do |index|
          theme = themes[index]
          needs_by_theme_size = theme.present? ? calculate_needs_by_theme_size(theme) : nil
          subject = subjects[index]
          needs_by_subject_size = subject.present? ? calculate_needs_by_subject_size(subject) : nil

          sheet.add_row [
            theme&.label,
            needs_by_theme_size,
            calculate_rate(needs_by_theme_size, @needs), nil,
            subject&.label,
            needs_by_subject_size,
            calculate_rate(needs_by_subject_size, @needs)
          ], style: count_rate_row_style
        end
        sheet.add_row
      end

      def generate_matches_stats
        sheet.add_row [
          I18n.t('antenne_stats_exporter.experts_positionning', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage'), nil,
          I18n.t('antenne_stats_exporter.experts_answering_rate', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage')
        ], style: count_rate_header_style

        (0...ordered_statuses.size).to_a.each do |index|
          match_status = ordered_statuses[index]
          match_status_size = matches.send("status_#{match_status}")&.size
          positionning_status = ordered_positionning_statuses[index]
          positionning_status_size = calculate_positionning_status_size(positionning_status, matches)
          sheet.add_row [
            I18n.t("activerecord.attributes.match/statuses/short.#{match_status}"),
            match_status_size,
            calculate_rate(match_status_size, matches), nil,
            positionning_status.present? ? I18n.t("antenne_stats_exporter.#{positionning_status}_rate") : nil,
            positionning_status_size,
            calculate_rate(positionning_status_size, matches)
          ], style: count_rate_row_style
        end
        sheet.add_row
      end

      def generate_needs_stats
        sheet.add_row [
          I18n.t('antenne_stats_exporter.ecosystem_positionning', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage'),nil,
          I18n.t('antenne_stats_exporter.ecosystem_answering_rate', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage')
        ], style: count_rate_header_style

        (0...ordered_statuses.size).to_a.each do |index|
          need_status = ordered_statuses[index]
          need_status_size = @needs.send("status_#{need_status}")&.size if need_status.present?
          positionning_status = ordered_positionning_statuses[index]
          positionning_status_size = calculate_positionning_status_size(positionning_status, @needs)
          sheet.add_row [
            need_status.present? ? I18n.t("activerecord.attributes.need/statuses/csv.#{need_status}") : nil,
            need_status_size || nil,
            calculate_rate(need_status_size, @needs), nil,
            positionning_status.present? ? I18n.t("antenne_stats_exporter.#{positionning_status}_rate") : nil,
            positionning_status_size,
            calculate_rate(positionning_status_size, matches)
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

      def institution_name
        @institution_name ||= @antenne.institution.name
      end

      def matches
        @matches ||= @antenne.perimeter_received_matches_from_needs(@needs)
      end

      def facilities
        @facilities ||= Facility.joins(diagnoses: :needs).where(diagnoses: { needs: @needs }).distinct
      end

      def ordered_statuses
        @ordered_statuses ||= [:done, :done_not_reachable, :done_no_help, :taking_care, :not_for_me, :quo]
      end

      def ordered_positionning_statuses
        @ordered_positionning_statuses ||= [:positionning, :positionning_accepted, :done, :not_for_me, :quo, nil]
      end

      # Calculation
      #
      def calculate_rate(status_size, base_relation)
        return unless status_size.present? && base_relation.present?
        status_size / base_relation.size.to_f
      end

      def calculate_positionning_status_size(status, base_relation)
        return unless status
        case status
        # Pris en charge, refusé, clôturé avec aide, clôturé sans aide, injoignable
        when :positionning
          base_relation.size - base_relation.status_quo.size
        # Pris en charge, clôturé avec aide, clôturé sans aide, injoignable
        when :positionning_accepted
          base_relation.size - (base_relation.status_quo.size + base_relation.status_not_for_me.size)
        else
          base_relation.send("status_#{status}")&.size
        end
      end

      def calculate_needs_by_theme_size(theme)
        @needs.joins(subject: :theme).where(subject: { theme: theme }).size
      end

      def calculate_needs_by_subject_size(subject)
        @needs.where(subject: subject).size
      end

      # Style
      #
      def create_styles(s)
        @subtitle     = s.add_style bg_color: 'DD', sz: 14, b: true, alignment: { horizontal: :center, vertical: :center }
        @bold         = s.add_style b: true
        @left_header  = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :left }
        @right_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :right }
        @label        = s.add_style alignment: { indent: 1 }
        @rate         = s.add_style format_code: '#0.0%'
        s
      end

      def count_rate_header_style
        [@left_header, @right_header, @right_header, nil, @left_header, @right_header, @right_header]
      end

      def count_rate_row_style
        [@label, nil, @rate, nil, @label, nil, @rate]
      end

      # Pages résumé
      #
      def add_agglomerate_headers
        sheet.add_row [
          I18n.t('antenne_stats_exporter.antenne'),
          I18n.t('antenne_stats_exporter.needs_count'),
          I18n.t('antenne_stats_exporter.needs_percentage'),
          I18n.t('antenne_stats_exporter.positionning_rate'),
          I18n.t('antenne_stats_exporter.positionning_accepted_rate'),
          I18n.t('antenne_stats_exporter.done_rate')
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header]
      end

      def add_agglomerate_rows(needs, ratio, row_title)
        matches = @antenne.perimeter_received_matches_from_needs(needs)
        positionning_size = calculate_positionning_status_size(:positionning, matches)
        positionning_accepted_size = calculate_positionning_status_size(:positionning_accepted, matches)
        done_size = calculate_positionning_status_size(:done, matches)
        sheet.add_row [
          row_title,
          needs.size,
          ratio,
          calculate_rate(positionning_size, matches),
          calculate_rate(positionning_accepted_size, matches),
          calculate_rate(done_size, matches),
        ], style: [nil, nil, @rate, @rate, @rate, @rate]
      end

      def finalise_agglomerate_style
        [
          'A1:G1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 15, 25, 25, 25
      end
    end
  end
end
