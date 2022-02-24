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
        sheet.add_row ["#{@antenne.name} - #{@end_date.year}T#{TimeDurationService.find_quarter(@start_date.month)}"], style: @header
        # sheet.add_row [antenne.name], style: header, offset: 1

        sheet.add_row
        sheet.add_row ["Besoins", @antenne.received_needs.uniq.size]
        sheet.add_row ["Etablissements", @antenne.received_facilities.uniq.size]

        # sheet.add_row
        # sheet.add_row ["What's coming in this month.", nil, nil, 'How am I doing'], style: tbl_header, offset: 1
        # sheet.add_row ['Item', 'Amount', nil, 'Item', 'Amount'], style: [ind_header, col_header, nil, ind_header, col_header], offset: 1
        # sheet.add_row ['Estimated monthly net income', 500, nil, 'Monthly income', '=C9'], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Financial aid', 100, nil, 'Monthly expenses', '=C27'], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Allowance from mom & dad', 20000, nil, 'Semester expenses', '=F19'], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Total', '=SUM(C6:C8)', nil, 'Difference', '=F6 - SUM(F7:F8)'], style: [t_label, t_money, nil, t_label, t_money], offset: 1

        # sheet.add_row
        # sheet.add_row ["What's going out this month.", nil, nil, 'Semester Costs'], style: tbl_header, offset: 1
        # sheet.add_row ['Item', 'Amount', nil, 'Item', 'Amount'], style: [ind_header, col_header, nil, ind_header, col_header], offset: 1
        # sheet.add_row ['Rent', 650, nil, 'Tuition', 200], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Utilities', 120, nil, 'Lab fees', 50], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Cell phone', 100, nil, 'Other fees', 10], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Groceries', 75, nil, 'Books', 150], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Auto expenses', 0, nil, 'Deposits', 0], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Student loans', 0, nil, 'Transportation', 30], style: [label, money, nil, label, money], offset: 1
        # sheet.add_row ['Other loans', 350, nil, 'Total', '=SUM(F13:F18)'], style: [label, money, nil, t_label, t_money], offset: 1
        # sheet.add_row ['Credit cards', 450], style: [label, money], offset: 1
        # sheet.add_row ['Insurance', 0], style: [label, money], offset: 1
        # sheet.add_row ['Laundry', 10], style: [label, money], offset: 1
        # sheet.add_row ['Haircuts', 0], style: [label, money], offset: 1
        # sheet.add_row ['Medical expenses', 0], style: [label, money], offset: 1
        # sheet.add_row ['Entertainment', 500], style: [label, money], offset: 1
        # sheet.add_row ['Miscellaneous', 0], style: [label, money], offset: 1
        # sheet.add_row ['Total', '=SUM(C13:C26)'], style: [t_label, t_money], offset: 1

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
      @ind_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { indent: 1 }
      @col_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :center }
      @label      = s.add_style alignment: { indent: 1 }
      @money      = s.add_style num_fmt: 5
      @t_label    = s.add_style b: true, bg_color: 'FFDFDEDF'
      @t_money    = s.add_style b: true, num_fmt: 5, bg_color: 'FFDFDEDF'
      s
    end

    def matches
      @antenne.received_matches.joins(need: { experts: { antenne: :institution }, facility: :commune }).created_between(@start_date, @end_date)
    end
  end
end