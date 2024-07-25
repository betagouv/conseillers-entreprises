class Conseiller::SuiviQualiteController < ApplicationController
  include PersistedSearch

  before_action :authenticate_admin!
  before_action :collections_counts

  layout 'side_menu'

  def index
    redirect_to action: :quo_matches
  end

  def quo_matches
    @needs = retrieve_quo_matches_needs
      .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
      .order(created_at: :asc)
      .page(params[:page])
    @action = :quo_match

    render :index
  end

  def refused_feedbacks
    @needs = retrieve_refused_feedbacks
      .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
      .order(created_at: :asc)
      .page(params[:page])
    @action = :refused_feedback

    render :index
  end

  private

  def retrieve_quo_matches_needs
    @quo_matches_needs ||= Need.apply_filters(index_search_params).with_filtered_matches_quo
  end

  def retrieve_refused_feedbacks
    @refused_feedbacks ||= Need.joins(:matches).merge(Match.with_recent_refused_feedbacks).apply_filters(index_search_params)
  end

  def collections_counts
    @collections_by_suivi_qualite_count = Rails.cache.fetch(['suivi_qualite', retrieve_quo_matches_needs.size, retrieve_refused_feedbacks.size]) do
      {
        quo_matches: retrieve_quo_matches_needs.size,
        refused_feedbacks: retrieve_refused_feedbacks.size
      }
    end
  end

  def search_session_key
    :suivi_qualite_search
  end

  def search_fields
    [:by_region]
  end
end
