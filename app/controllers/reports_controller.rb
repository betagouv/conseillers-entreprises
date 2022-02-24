class ReportsController < ApplicationController
  before_action :last_quarters

  def index
    @antenne = current_user.antenne
    authorize :report, :index?
  end

  def download_matches
    quarterly_report = QuarterlyReport.find_by(id: params[:id], antenne: current_user.antenne)
    authorize quarterly_report, policy_class: ReportPolicy
    respond_to do |format|
      format.html
      format.xlsx do
        send_data quarterly_report.file.download, type: "application/xlsx", filename: quarterly_report.file.filename.to_s
      end
    end
  end

  def download_antenne_stats
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    xlsx_filename = t('.xslx_filename', antenne: current_user.antenne.name.parameterize, number: TimeDurationService.find_quarter(start_date.month), year: start_date.year)

    exporter = XlsxExport::AntenneStatsExporter.new({
      start_date: start_date,
      end_date: end_date,
      antenne: current_user.antenne
    })

    respond_to do |format|
      format.xlsx do
        result = exporter.export
        send_data result.xlsx, type: "application/xlsx", filename: xlsx_filename
      end
    end

  end

  private

  def last_quarters
    return if current_user.antenne.received_matches.blank?
    first_match_date = current_user.antenne.received_matches.first.created_at.to_date
    @quarters = TimeDurationService.past_year_quarters
    @quarters.reject! { |range| first_match_date > range.last }
  end
end
