module XlsxExport
  class CooperationExporter < BaseExporter
    def initialize(params)
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @cooperation = params[:cooperation]
    end

    def xlsx
      p = Axlsx::Package.new
      wb = p.workbook
      title = wb.styles.add_style bg_color: 'eadecd', sz: 16, b: true, alignment: { horizontal: :center, vertical: :center }, border: { color: 'AAAAAA', style: :thin }
      solicitations = Solicitation.step_complete.where(cooperation_id: @cooperation.id)
      year_start_date = @start_date.beginning_of_year

      # Volume stats
      wb.add_worksheet(name: I18n.t('cooperation_stats_exporter.volume.tab')) do |sheet|
        period = "#{@end_date.year}T#{TimeDurationService.find_quarter_for_month(@start_date.month)}"
        sheet.add_row [I18n.t('cooperation_stats_exporter.volume.title', cooperation: @cooperation.name, period: period)], style: title
        XlsxExport::CooperationWorksheetGenerator::Volume.new(sheet, @cooperation, @start_date, @end_date, wb.styles).generate
      end

      # Répartition stats
      wb.add_worksheet(name: I18n.t('cooperation_stats_exporter.repartition.tab')) do |sheet|
        period = "#{@end_date.year}T#{TimeDurationService.find_quarter_for_month(@start_date.month)}"
        sheet.add_row [I18n.t('cooperation_stats_exporter.repartition.title', cooperation: @cooperation.name, period: period)], style: title
        XlsxExport::CooperationWorksheetGenerator::Repartition.new(sheet, @cooperation, @start_date, @end_date, wb.styles).generate
      end

      p.use_shared_strings = true
      p
    end
  end
end
