class Conseiller::VeilleController < ApplicationController
  include PersistedSearch
  include Inbox

  helper_method :inbox_collections_counts

  before_action :authenticate_admin!
  before_action :collections_counts

  layout 'side_menu'

  def starred_needs
    @needs = retrieve_starred_needs
      .with_card_includes
      .order(created_at: :asc)
      .page(params[:page])
    @action = :starred_need
  end

  def taking_care_matches
    @experts = retrieve_taking_care_matches_experts
      .includes(:received_needs)
      .preload(:users, :antenne)
      .order(created_at: :asc)
      .page(params[:page])
    @action = :taking_care_matches
  end

  def send_closing_good_practice_email
    expert = Expert.find(params.permit(:id)[:id])
    ExpertMailer.with(expert: expert).closing_good_practice.deliver_later
    Feedback.create(user: current_user, category: :expert_reminder, description: t('reminders.experts.send_closing_good_practice_email.email_send'),
                    feedbackable_type: 'Expert', feedbackable_id: expert.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("display-feedbacks-#{expert.id}",
                                                 partial: "experts/expert_feedbacks",
                                                 locals: { expert: expert })
        format.html { redirect_back fallback_location: taking_care_matches_conseiller_veille_index_path }
      end
    end
  end

  private

  def retrieve_starred_needs
    Need.starred.apply_filters(index_search_params)
  end

  def retrieve_taking_care_matches_experts
    Expert
      .with_taking_care_stock
      .active
      .apply_filters(index_search_params)
      .distinct
  end

  def collections_counts
    @collections_by_veille_count = Rails.cache.fetch(['veille', retrieve_taking_care_matches_experts.size, retrieve_starred_needs.size]) do
      {
        starred_needs: retrieve_starred_needs.size,
        taking_care_matches: retrieve_taking_care_matches_experts.to_a.size
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
