module ActivityReports
  class Generate::CooperationSolicitations < Generate::Base
    private

    def export_xls(quarter)
      exporter = XlsxExport::CooperationSolicitationsExporter.new({
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
      :solicitations
    end

    def reports
      cooperation.solicitations_reports
    end
  end
end
