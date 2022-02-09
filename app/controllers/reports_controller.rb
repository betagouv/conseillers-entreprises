class ReportsController < ApplicationController
  before_action :last_quarters

  def index
    authorize :report, :index?
  end

  def download_matches
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    xlsx_filename = t('.xslx_name', number: TimeDurationService.find_quarter(start_date.month), year: start_date.year)

    @matches = Match.user_antenne_territory_needs(current_user, start_date, end_date)

    respond_to do |format|
      format.html
      format.xlsx do
        result = @matches.export_xlsx
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
