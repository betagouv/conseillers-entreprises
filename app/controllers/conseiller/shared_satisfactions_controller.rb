class Conseiller::SharedSatisfactionsController < ApplicationController
  before_action :collections_counts, except: :mark_as_seen
  skip_before_action :verify_authenticity_token, only: :mark_as_seen

  layout 'side_menu'

  def index
    redirect_to action: :unseen
  end

  def unseen
    @needs = retrieve_unseen_satisfactions
      .order(:created_at)
      .page(params[:page])

    render :index
  end

  def seen
    @needs = retrieve_seen_satisfactions
      .order(:created_at)
      .page(params[:page])

    render :index
  end

  def mark_as_seen
    @shared_satisfaction = SharedSatisfaction.find(params[:id])
    authorize @shared_satisfaction
    if @shared_satisfaction.touch(:seen_at)
      flash.notice = t('conseiller.shared_satisfactions.satifaction_seen')
    else
      flash.alert = @shared_satisfaction.errors.full_messages.to_sentence
    end
    redirect_to action: :unseen
  end

  private

  def retrieve_unseen_satisfactions
    @unseen_satisfactions ||= current_user.received_needs
      .joins(company_satisfaction: :shared_satisfactions)
      .merge(SharedSatisfaction.unseen.where(user_id: current_user.id))
      .distinct
  end

  def retrieve_seen_satisfactions
    @seen_satisfactions ||= current_user.received_needs
      .joins(company_satisfaction: :shared_satisfactions)
      .merge(SharedSatisfaction.seen.where(user_id: current_user.id))
      .distinct
  end

  def collections_counts
    @satisfaction_collections_count = Rails.cache.fetch(['satisfaction', retrieve_unseen_satisfactions.size, retrieve_seen_satisfactions.size]) do
      {
        unseen: retrieve_unseen_satisfactions.size,
        seen: retrieve_seen_satisfactions.size,
      }
    end
  end
end
