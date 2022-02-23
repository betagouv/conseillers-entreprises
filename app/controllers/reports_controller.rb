class ReportsController < ApplicationController
  before_action :last_quarters

  def index
    @antenne = current_user.antenne
    authorize :report, :index?
  end

  def download_matches
    quarterly_data = QuarterlyData.find_by(id: params[:id], antenne: current_user.antenne)
    authorize quarterly_data, policy_class: ReportPolicy
    respond_to do |format|
      format.html
      format.xlsx do
        send_data quarterly_data.file.download, type: "application/xlsx", filename: quarterly_data.file.filename.to_s
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
