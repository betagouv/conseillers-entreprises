class ReportsController < ApplicationController
  include SearchFilters

  before_action :retrieve_antenne, only: [:stats, :matches]
  before_action :retrieve_quarters, only: [:stats]

  layout 'side_menu', only: [:stats, :matches]

  def index
    redirect_to action: :stats, antenne_id: params[:antenne_id]
  end

  def stats; end

  def matches
    @grouped_reports = @antenne.matches_reports.order(start_date: :desc).group_by{ |r| r.start_date.year }
  end

  def download
    report = ActivityReport.find(params.expect(:id))
    authorize report.antenne, "#{report.category}?", policy_class: ReportPolicy # report.category is 'matches' or 'stats' which maps to the ReportPolicy query names.

    send_data report.file.download, type: "application/xlsx", filename: report.file.filename.to_s
  end

  private

  def retrieve_antenne
    @antenne = if params[:antenne_id].present?
      Antenne.find(params.expect(:antenne_id))
    else
      current_user.managed_antennes.by_higher_territorial_level.first || current_user.sponsored_institutions.first&.antennes&.first
    end
    authorize @antenne, policy_class: ReportPolicy
    initialize_filters([:antennes])
  end

  def retrieve_quarters
    @quarters = @antenne.stats_reports.order(start_date: :desc).pluck(:start_date, :end_date).uniq
  end

  # SearchFilter
  def base_needs_for_filters
    @base_needs_for_filters ||= @antenne.perimeter_received_needs.distinct
  end
end
