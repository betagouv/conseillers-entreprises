class ActivityReports::CooperationSolicitations < ActivityReports::Generate::Base
  class Enqueue < ApplicationJob::LowPriority
    def perform
      Cooperation.not_archived
        .where(wants_solicitations_export: true)
        .find_each { Generate.perform_later(it) }
    end
  end

  class Generate < ApplicationJob::LowPriority
    def perform = ActivityReports::CooperationSolicitations.new(cooperation).call
  end

  ##

  def export_xls(quarter)
    XlsxExport::CooperationSolicitationsExporter
      .new(start_date: quarter.first, end_date: quarter.last, cooperation: cooperation)
      .export
  end

  def cooperation = @item

  def report_type = :solicitations

  def reports = cooperation.solicitations_reports
end
