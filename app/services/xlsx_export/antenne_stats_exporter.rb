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

      create_styles wb.styles

      wb.add_worksheet(name: "stats") do |sheet|
        sheet.add_row ["#{@antenne.name} - #{@end_date.year}T#{TimeDurationService.find_quarter(@start_date.month, 'to_number')}"], style: @header
        # sheet.add_row [antenne.name], style: header

        sheet.add_row
        sheet.add_row [I18n.t('antenne_stats_exporter.needs'), needs.size]
        sheet.add_row [I18n.t('antenne_stats_exporter.matches'), matches.size]
        sheet.add_row [I18n.t('antenne_stats_exporter.facilities'), facilities.size]
        sheet.add_row

        ordered_match_statuses = [:done_not_reachable, :done, :done_no_help, :not_for_me, :quo, :taking_care]
        ordered_positionning_statuses = [:positionning, :positionning_accepted, :done, :not_for_me, :quo, nil]

        sheet.add_row [I18n.t('attributes.match_status'), I18n.t('antenne_stats_exporter.count'), I18n.t('antenne_stats_exporter.percentage'),nil, I18n.t('antenne_stats_exporter.answer_rate'), I18n.t('antenne_stats_exporter.count'), I18n.t('antenne_stats_exporter.percentage')], style: [@left_header, @right_header, @right_header, nil, @left_header, @right_header, @right_header]
        (0...ordered_match_statuses.size).to_a.each do |index|
          status = ordered_match_statuses[index]
          positionning_status = ordered_positionning_statuses[index]
          match_status_size = matches.send("status_#{status}")&.size
          positionning_status_size = calculate_positionning_status_size(positionning_status)
          sheet.add_row [
            I18n.t("activerecord.attributes.match/statuses/short.#{status}"),
            match_status_size,
            match_status_rate(match_status_size), nil,
            positionning_status.present? ? I18n.t("antenne_stats_exporter.#{positionning_status}_rate") : nil,
            positionning_status_size,
            match_status_rate(positionning_status_size)
          ], style: count_rate_row_style
        end
        sheet.add_row


        # sheet.add_row ['Estimated monthly net income', 500, nil, 'Monthly income', '=C9'], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Financial aid', 100, nil, 'Monthly expenses', '=C27'], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Allowance from mom & dad', 20000, nil, 'Semester expenses', '=F19'], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Total', '=SUM(C6:C8)', nil, 'Difference', '=F6 - SUM(F7:F8)'], style: [t_@label, t_@money, nil, t_@label, t_@money]

        # sheet.add_row
        # sheet.add_row ["What's going out this month.", nil, nil, 'Semester Costs'], style: tbl_header
        # sheet.add_row ['Item', 'Amount', nil, 'Item', 'Amount'], style: [@left_header, @right_header, nil, @left_header, @right_header]
        # sheet.add_row ['Rent', 650, nil, 'Tuition', 200], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Utilities', 120, nil, 'Lab fees', 50], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Cell phone', 100, nil, 'Other fees', 10], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Groceries', 75, nil, 'Books', 150], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Auto expenses', 0, nil, 'Deposits', 0], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Student loans', 0, nil, 'Transportation', 30], style: [@label, @money, nil, @label, @money]
        # sheet.add_row ['Other loans', 350, nil, 'Total', '=SUM(F13:F18)'], style: [@label, @money, nil, t_@label, t_@money]
        # sheet.add_row ['Credit cards', 450], style: [@label, @money]
        # sheet.add_row ['Insurance', 0], style: [@label, @money]
        # sheet.add_row ['Laundry', 10], style: [@label, @money]
        # sheet.add_row ['Haircuts', 0], style: [@label, @money]
        # sheet.add_row ['Medical expenses', 0], style: [@label, @money]
        # sheet.add_row ['Entertainment', 500], style: [@label, @money]
        # sheet.add_row ['Miscellaneous', 0], style: [@label, @money]
        # sheet.add_row ['Total', '=SUM(C13:C26)'], style: [t_@label, t_@money]

        # [
        #   'B4:C4',
        #   'E4:F4',
        #   'B11:C11',
        #   'E11:F11',
        #   'B2:F2'
        # ].each { |range| sheet.merge_cells(range) }

        # sheet.column_widths 2, nil, nil, 2, nil, nil, 2
      end

      p.use_shared_strings = true
      p.to_stream.read
    end

    def create_styles(s)
      @header     = s.add_style bg_color: 'DD', sz: 16, b: true, alignment: { horizontal: :center }
      @tbl_header = s.add_style b: true, alignment: { horizontal: :center }
      @left_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :left }
      @right_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :right }
      @label      = s.add_style alignment: { indent: 1 }
      @rate      = s.add_style format_code: '#0.0%'
      @t_label    = s.add_style b: true, bg_color: 'FFDFDEDF'
      @t_money    = s.add_style b: true, num_fmt: 5, bg_color: 'FFDFDEDF'
      s
    end

    def count_rate_row_style
      [@label, nil, @rate, nil, @label, nil, @rate]
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
    def match_status_rate(status_size)
      return unless status_size
      status_size / matches.size.to_f
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
  end
end
