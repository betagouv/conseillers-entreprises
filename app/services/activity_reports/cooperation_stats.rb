class ActivityReports::CooperationStats < ActivityReports::GeneratorBase
  class Enqueue < EnqueueBase
    def collection = Cooperation.not_archived
  end

  def export_xls(quarter)
    XlsxExport::CooperationExporter
      .new(start_date: quarter.first, end_date: quarter.last, cooperation: @item)
      .export
  end

  def report_type = :cooperation

  def reports_periods = TimeDurationService.quarters
end
