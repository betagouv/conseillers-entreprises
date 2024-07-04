class Conseiller::SharedSatisfactionsController < ApplicationController
  before_action :collections_counts, except: [:mark_as_seen, :mark_all_as_seen]

  layout 'side_menu'

  def index
    redirect_to action: :unseen
  end

  def unseen
    @antennes = retrieve_antennes if current_user.is_manager?
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
    @shared_satisfaction.touch(:seen_at)
    respond_to do |format|
      format.turbo_stream do
        collections_counts
      end
      format.html do
        flash.notice = t('conseiller.shared_satisfactions.satifaction_seen')
        redirect_to action: :unseen, anchor: 'side-menu-main'
      end
    end
  end

  def mark_all_as_seen
    @shared_satisfactions = SharedSatisfaction.where(id: params[:shared_satisfactions_id])
    @shared_satisfactions.update_all(seen_at: Time.zone.now)
    flash.notice = t('conseiller.shared_satisfactions.satifaction_seen')
    redirect_to action: :unseen
  end

  private

  def retrieve_unseen_satisfactions
    @unseen_satisfactions ||= base_needs
      .joins(company_satisfaction: :shared_satisfactions)
      .merge(SharedSatisfaction.unseen.where(user_id: current_user.id))
      .distinct
  end

  def retrieve_seen_satisfactions
    @seen_satisfactions ||= base_needs
      .joins(company_satisfaction: :shared_satisfactions)
      .merge(SharedSatisfaction.seen.where(user_id: current_user.id))
      .distinct
  end

  def base_needs
    base_needs = if current_user.is_manager?
      current_user.antenne.perimeter_received_needs.apply_filters(filter_params)
    else
      current_user.received_needs
    end
    base_needs.includes(:company, :subject, :facility, company_satisfaction: :shared_satisfactions)
  end

  def retrieve_antennes
    ids = (current_user.managed_antenne_ids + current_user.managed_antennes.map { |a| a.territorial_antennes.pluck(:id) }).flatten
    Antenne.with_experts_subjects.not_deleted.where(id: ids).order(:name)
  end

  def collections_counts
    @satisfaction_collections_count = Rails.cache.fetch(['satisfaction', retrieve_unseen_satisfactions.size, retrieve_seen_satisfactions.size]) do
      {
        unseen: retrieve_unseen_satisfactions.size,
        seen: retrieve_seen_satisfactions.size,
      }
    end
  end

  def filter_params
    params.permit(:antenne_id)
  end
end
