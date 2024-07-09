class Conseiller::VeilleController < ApplicationController
  include PersistedSearch

  before_action :authenticate_admin!
  before_action :collections_counts

  layout 'side_menu'

  def index
    redirect_to action: :starred_needs
  end

  def starred_needs
    @needs = retrieve_starred_needs
      .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
      .order(created_at: :asc)
      .page(params[:page])
    @action = :starred_need

    render :index
  end

  def taking_care_matches
    @needs = retrieve_taking_care_matches_needs
      .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
      .order(created_at: :asc)
      .page(params[:page])
    @action = :quo_match

    render :index
  end

  private

  def retrieve_starred_needs
    @starred_needs ||= Need.apply_filters(index_search_params).starred
  end

  def retrieve_taking_care_matches_needs
    @taking_care_matches_needs ||= Need.apply_filters(index_search_params).with_filtered_matches_taking_care
  end

  def collections_counts
    @collections_by_veille_count = Rails.cache.fetch(['veille', retrieve_taking_care_matches_needs.size, retrieve_starred_needs.size]) do
      {
        starred_needs: retrieve_starred_needs.size,
        taking_care_matches: retrieve_taking_care_matches_needs.size
      }
    end
  end

  def search_session_key
    :veille_search
  end

  def search_fields
    [:by_region]
  end
end
