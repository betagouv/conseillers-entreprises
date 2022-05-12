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
      title = wb.styles.add_style bg_color: 'DD', sz: 16, b: true, alignment: { horizontal: :center, vertical: :center }
      needs = @antenne.perimeter_received_needs

      # Quarter stats
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{@end_date.year}T#{TimeDurationService.find_quarter(@start_date.month)}"], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::Base.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
      end

      # Detailed stats
      if @antenne.national?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats_by_region')) do |sheet|
          sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.by_region')} - #{@end_date.year}T#{TimeDurationService.find_quarter(@start_date.month)}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::ByRegion.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
        end
      elsif @antenne.regional?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats_by_antenne')) do |sheet|
          sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.by_antenne')} - #{@end_date.year}T#{TimeDurationService.find_quarter(@start_date.month)}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::ByAntenne.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
        end
      end

      # Annual stats
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.year_stats')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: title
        year_start_date = @start_date.beginning_of_year
        XlsxExport::AntenneStatsWorksheetGenerator::Base.new(sheet, @antenne, needs.created_between(year_start_date, @end_date), wb.styles).generate
      end

      # Légende
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.caption_title')) do |sheet|
        sheet.add_row [I18n.t('antenne_stats_exporter.caption_title')], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::Caption.new(sheet, @antenne, wb.styles).generate
      end

      p.use_shared_strings = true
      p
    end
  end
end
