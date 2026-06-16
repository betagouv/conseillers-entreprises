class ActivityReports::CooperationSolicitations < ActivityReports::GeneratorBase
  class Enqueue < EnqueueBase
    def collection = Cooperation.not_archived.where(wants_solicitations_export: true)
  end

  def export_xls(quarter)
    XlsxExport::CooperationSolicitationsExporter
      .new(start_date: quarter.first, end_date: quarter.last, cooperation: @item)
      .export
  end

  def report_type = :solicitations

  def reports_periods = TimeDurationService.quarters
end
