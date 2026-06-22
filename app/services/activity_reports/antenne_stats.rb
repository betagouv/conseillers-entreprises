class ActivityReports::AntenneStats < ActivityReports::GeneratorBase
  class Enqueue < EnqueueBase
    def collection = Antenne.not_deleted
  end

  def export_xls(quarter)
    XlsxExport::AntenneStatsExporter
      .new(start_date: quarter.first, end_date: quarter.last, antenne: @item)
      .export
  end

  def report_type = :stats

  def reports_periods = ActivityPeriods.quarters
end
