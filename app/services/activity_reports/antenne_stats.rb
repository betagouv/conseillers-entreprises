class ActivityReports::AntenneStats < ActivityReports::GeneratorBase
  class Enqueue < EnqueueBase
    def collection = Antenne.not_deleted
  end

  def export_xls(quarter)
    XlsxExport::AntenneStatsExporter
      .new(start_date: quarter.first, end_date: quarter.last, antenne: antenne)
      .export
  end

  def antenne = @item

  def report_type = :stats

  def reports = antenne.stats_reports
end
