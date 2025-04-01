module ActivityReports
  class Generate::AntenneStats < Generate::Base
    private

    def export_xls(quarter)
      exporter = XlsxExport::AntenneStatsExporter.new({
        start_date: quarter.first,
          end_date: quarter.last,
          antenne: antenne
      })
      exporter.export
    end

    def antenne
      @item
    end

    def last_periods
      last_quarters
    end

    def report_type
      :stats
    end

    def reports
      antenne.stats_reports
    end
  end
end
