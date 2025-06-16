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
      title = wb.styles.add_style bg_color: 'eadecd', sz: 16, b: true, alignment: { horizontal: :center, vertical: :center }, border: { color: 'AAAAAA', style: :thin }
      needs = @antenne.perimeter_received_needs.joins(:diagnosis).merge(Diagnosis.from_solicitation)
      year_start_date = @start_date.beginning_of_year
      period = "#{@end_date.year}T#{TimeDurationService::Quarters.new.find_quarter_for_month(@start_date.month)}"

      # Quarter stats
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{period}"], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::ByPosition.new(sheet, @antenne, needs, @start_date, @end_date, :quarter, wb.styles).generate
      end

      # Quarter stats by subject
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats_by_subject')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{period}"], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::BySubject.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
      end

      # Agglomerate stats
      if @antenne.national?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats_by_region')) do |sheet|
          sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.by_region')} - #{period}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::ByTerritory.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
        end
      elsif @antenne.regional? && @antenne.territorial_antennes.any?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.quarter_stats_by_antenne')) do |sheet|
          sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.by_antenne')} - #{period}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::ByAntenne.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
        end
      end

      # Annual stats
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.year_stats')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::ByPosition.new(sheet, @antenne, needs, year_start_date, @end_date, :annual, wb.styles).generate
      end

      # Annual stats by subject
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.year_stats_by_subject')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::BySubject.new(sheet, @antenne, needs.created_between(year_start_date, @end_date), wb.styles).generate
      end

      # Annual agglomerate stats
      if @antenne.national?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.annual_stats_by_region')) do |sheet|
          sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::ByTerritory.new(sheet, @antenne, needs.created_between(year_start_date, @end_date), wb.styles).generate
        end
      elsif @antenne.regional? && @antenne.territorial_antennes.any?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.annual_stats_by_antenne')) do |sheet|
          sheet.add_row ["#{@antenne.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::ByAntenne.new(sheet, @antenne, needs.created_between(year_start_date, @end_date), wb.styles).generate
        end
      end

      # National stats
      unless @antenne.national?
        wb.add_worksheet(name: I18n.t('antenne_stats_exporter.annual_national_stats')) do |sheet|
          sheet.add_row ["#{@antenne.institution.name} - #{I18n.t('antenne_stats_exporter.from_beginning_of_year', year: @start_date.year)}"], style: title
          XlsxExport::AntenneStatsWorksheetGenerator::National.new(sheet, @antenne, @antenne.institution.perimeter_received_needs.created_between(year_start_date, @end_date), wb.styles).generate
        end
      end

      # Refusals
      wb.add_worksheet(name: I18n.t('antenne_stats_exporter.refusals')) do |sheet|
        sheet.add_row ["#{@antenne.name} - #{period}"], style: title
        XlsxExport::AntenneStatsWorksheetGenerator::ByRefusedSubject.new(sheet, @antenne, needs.created_between(@start_date, @end_date), wb.styles).generate
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
