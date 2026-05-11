class ActivityReports::AntenneStats < ActivityReports::Generate::Base
  class Enqueue < ApplicationJob::LowPriority
    def perform = Antenne.not_deleted.find_each { Generate.perform_later(it) }
  end

  class Generate < ApplicationJob::LowPriority
    def perform(antenne) = ActivityReports::AntenneStats.new(antenne).call
  end

  ##

  def export_xls(quarter)
    XlsxExport::AntenneStatsExporter
      .new(start_date: quarter.first, end_date: quarter.last, antenne: antenne)
      .export
  end

  def antenne = @item

  def report_type = :stats

  def reports = antenne.stats_reports
end
