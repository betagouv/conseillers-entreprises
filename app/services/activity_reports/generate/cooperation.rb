module ActivityReports
  class Generate::Cooperation < Generate::Base
    private

    def generate_files(quarter)
      return if reports.find_by(start_date: quarter.first).present?

      ActiveRecord::Base.transaction do
        exporter = XlsxExport::CooperationExporter.new({
          start_date: quarter.first,
          end_date: quarter.last,
          cooperation: cooperation
        })
        result = exporter.export

        filename = I18n.t('activity_report_service.cooperation_file_name', number: TimeDurationService.find_quarter_for_month(quarter.first.month), year: quarter.first.year, cooperation: cooperation.name.parameterize)
        report = reports.create!(start_date: quarter.first, end_date: quarter.last)
        report.file.attach(io: result.xlsx.to_stream(true),
                           key: "activity_report_cooperation/#{cooperation.name.parameterize}/#{filename}",
                           filename: filename,
                           content_type: 'application/xlsx')
      end
    end

    def cooperation
      @item
    end

    def last_periods
      last_quarters
    end

    def reports
      cooperation.activity_reports
    end
  end
end
