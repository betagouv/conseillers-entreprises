class ReportsController < ApplicationController
  before_action :retrieve_antenne, only: [:stats, :matches]
  before_action :retrieve_quarters, only: [:stats]

  layout 'side_menu', only: [:stats, :matches]

  def index
    authorize :activity_report
    redirect_to action: :stats, antenne_id: params[:antenne_id]
  end

  def stats; end

  def matches
    @grouped_reports = @antenne.matches_reports.order(start_date: :desc).group_by{ |r| r.start_date.year }
  end

  def download
    report = ActivityReport.find(params.expect(:id))
    authorize report, "#{report.category}?"

    send_data report.file.download, type: "application/xlsx", filename: report.file.filename.to_s
  end

  private

  def retrieve_antenne
    @antennes = BuildAntennesCollection.new(current_user).for_manager_or_sponsor
    antenne_hash = if params[:antenne_id]
      @antennes.find{ it[:id].to_s == params.expect(:antenne_id) }
    else
      @antennes.find { it[:id].to_s.include?('aggregate') } || @antennes.first
    end

    @antenne = Antenne.find(antenne_hash[:id])
    authorize @antenne.activity_reports.new(category: action_name)
  end

  def retrieve_quarters
    @quarters = @antenne.stats_reports.order(start_date: :desc).pluck(:start_date, :end_date).uniq
  end
end
