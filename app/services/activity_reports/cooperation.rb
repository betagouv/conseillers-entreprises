class ActivityReports::Cooperation < ActivityReports::Generate::Base
  class Enqueue < ApplicationJob::LowPriority
    def perform = Cooperation.not_archived.find_each { Generate.perform_later(it) }
  end

  class Generate < ApplicationJob::LowPriority
    def perform(cooperation) = ActivityReports::Generate::Cooperation.new(cooperation).call
  end

  ##

  def export_xls(quarter)
    XlsxExport::CooperationExporter
      .new(start_date: quarter.first, end_date: quarter.last, cooperation: cooperation)
      .export
  end

  def cooperation = @item

  def report_type = :cooperation

  def reports = cooperation.cooperation_reports
end
