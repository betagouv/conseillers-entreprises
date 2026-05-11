class ActivityReports::CooperationSolicitations < ActivityReports::GeneratorBase
  class Enqueue < EnqueueBase
    def collection = Cooperation.not_archived.where(wants_solicitations_export: true)
  end

  def export_xls(quarter)
    XlsxExport::CooperationSolicitationsExporter
      .new(start_date: quarter.first, end_date: quarter.last, cooperation: cooperation)
      .export
  end

  def cooperation = @item

  def report_type = :solicitations

  def reports = cooperation.solicitations_reports
end
