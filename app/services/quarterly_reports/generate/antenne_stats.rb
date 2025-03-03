module QuarterlyReports
  class Generate::AntenneStats < Generate::Base

    private

    def generate_files(quarter)
      return if reports.find_by(start_date: quarter.first).present?

      ActiveRecord::Base.transaction do
        exporter = XlsxExport::AntenneStatsExporter.new({
          start_date: quarter.first,
          end_date: quarter.last,
          antenne: @antenne
        })
        result = exporter.export

        filename = I18n.t('quarterly_report_service.stats_file_name', number: TimeDurationService.find_quarter_for_month(quarter.first.month), year: quarter.first.year, antenne: @antenne.name.parameterize)
        report = reports.create!(start_date: quarter.first, end_date: quarter.last)
        report.file.attach(io: result.xlsx.to_stream(true),
                           key: "quarterly_report_stats/#{@antenne.name.parameterize}/#{filename}",
                           filename: filename,
                           content_type: 'application/xlsx')
      end
    end


    def last_periods
      last_quarters
    end

    def reports
      @antenne.stats_reports
    end
  end
end
