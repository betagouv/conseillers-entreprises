class ReportsController < ApplicationController
  before_action :retrieve_antennes, except: :download
  before_action :retrieve_antenne
  before_action :retrieve_quarters, except: :download

  layout 'side_menu'

  def index
    authorize @antenne, policy_class: ReportPolicy
  end

  def download
    quarterly_report = @antenne.quarterly_reports.find_by(id: params[:id])
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
    @antenne = if params[:id].present?
      Antenne.find(params[:id])
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
