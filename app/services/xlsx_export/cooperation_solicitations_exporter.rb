module XlsxExport
  class CooperationSolicitationsExporter < BaseExporter
    def initialize(params)
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @cooperation = params[:cooperation]
    end

    def xlsx
      p = Axlsx::Package.new
      wb = p.workbook
      title = wb.styles.add_style bg_color: 'eadecd', sz: 16, b: true, alignment: { horizontal: :center, vertical: :center }, border: { color: 'AAAAAA', style: :thin }
      period = "#{@end_date.year}T#{TimeDurationService::Quarters.new.find_quarter_for_month(@start_date.month)}"

      # Solicitations
      wb.add_worksheet(name: I18n.t('cooperation_stats_exporter.solicitations.tab')) do |sheet|
        sheet.add_row [I18n.t('cooperation_stats_exporter.solicitations.title', cooperation: @cooperation.name, period: period)], style: title
        XlsxExport::CooperationWorksheetGenerator::Solicitations.new(sheet, @cooperation, @start_date, @end_date, wb.styles).generate
      end

      p.use_shared_strings = true
      p
    end
  end
end
