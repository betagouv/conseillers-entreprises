class ReportsController < ApplicationController
  before_action :retrieve_antennes, only: :index
  before_action :retrieve_antenne, only: :index
  before_action :retrieve_quarters, only: :index

  layout 'side_menu'

  def index
    authorize @antenne, policy_class: ReportPolicy
  end

  def download
    quarterly_report = QuarterlyReport.find(params[:id])
    authorize quarterly_report, policy_class: ReportPolicy
    respond_to do |format|
      format.html
      format.xlsx do
        send_data quarterly_report.file.download, type: "application/xlsx", filename: quarterly_report.file.filename.to_s
      end
    end
  end

  private

  def retrieve_antenne
    @antenne = if params[:antenne_id].present?
      Antenne.find(params[:antenne_id])
    else
      @antennes.first
    end
  end

  def retrieve_antennes
    @antennes = current_user.managed_antennes.order(:name)
  end

  def retrieve_quarters
    @quarters = @antenne.quarterly_reports.order(start_date: :desc).pluck(:start_date, :end_date).uniq
  end
end
