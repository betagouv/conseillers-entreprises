module ActivityReports
  class Generate::Cooperation < Generate::Base
    private

    def export_xls(quarter)
      exporter = XlsxExport::CooperationExporter.new({
        start_date: quarter.first,
          end_date: quarter.last,
          cooperation: cooperation
      })
      exporter.export
    end

    def cooperation
      @item
    end

    def report_type
      :cooperation
    end

    def reports
      cooperation.cooperation_reports
    end
  end
end
