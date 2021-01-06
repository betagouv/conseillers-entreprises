class SolicitationsController < ApplicationController
  before_action :find_solicitation, only: [:show, :update_status, :update_badges, :prepare_diagnosis]
  before_action :authorize_index_solicitation, only: [:index, :processed, :canceled]
  before_action :authorize_update_solicitation, only: [:update_status]
  before_action :set_category_content, only: %i[index processed canceled]
  before_action :find_territories, only: %i[index in_progress processed canceled]
  before_action :count_solicitations, only: %i[index in_progress processed canceled]

  layout 'side_menu'

  def index
    @solicitations = ordered_solicitations.without_feedbacks
    @status = t('solicitations.header.index')
  end

  def in_progress
    @solicitations = ordered_solicitations.with_feedbacks
    @status = t('solicitations.header.in_progress')
    render :index
  end

  def processed
    @solicitations = ordered_solicitations.status_processed
    @status = t('solicitations.header.processed')
    render :index
  end

  def canceled
    @solicitations = ordered_solicitations.status_canceled
    @status = t('solicitations.header.canceled')
    render :index
  end

  def show
    authorize @solicitation
    nb_per_page = Solicitation.page(1).limit_value
    case @solicitation.status
    when 'canceled'
      page = Solicitation.status_canceled.where('updated_at > ?',@solicitation.updated_at).count / nb_per_page + 1
      redirect_to canceled_solicitations_path(anchor: @solicitation.id, page: page)
    when 'processed'
      page = Solicitation.status_processed.where('updated_at > ?',@solicitation.updated_at).count / nb_per_page + 1
      redirect_to processed_solicitations_path(anchor: @solicitation.id, page: page)
    else
      page = Solicitation.status_in_progress.where('updated_at > ?',@solicitation.updated_at).count / nb_per_page + 1
      redirect_to solicitations_path(anchor: @solicitation.id, page: page)
    end
  end

  def update_status
    status = params[:status]
    @solicitation.update(status: status)
    if @solicitation.valid?
      done = Solicitation.human_attribute_value(:status, status, context: :done, count: 1)
      flash.notice = "#{@solicitation} #{done}"
      render 'remove'
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      redirect_to @solicitation
    end
  end

  def update_badges
    badges_params = params.require(:solicitation).permit(badge_ids: [])
    if @solicitation.valid?
      @solicitation.update(badges_params)
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      redirect_to @solicitation
    end
  end

  def prepare_diagnosis
    diagnosis = @solicitation.prepare_diagnosis(current_user)
    if diagnosis
      redirect_to diagnosis
    else
      flash.alert = @solicitation.prepare_diagnosis_errors.full_messages.to_sentence
      redirect_to @solicitation
    end
  end

  private

  def ordered_solicitations
    solicitations = Solicitation.order(created_at: :desc)
    solicitations = solicitations.by_possible_territory(params[:territory]) if params[:territory].present?
    solicitations.page(params[:page]).omnisearch(params[:query]).distinct
      .includes(:badges_solicitations, :badges, :institution, :landing, :diagnoses)
  end

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def authorize_update_solicitation
    authorize @solicitation, :update?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, :full_name, form_info: {}, needs: {})
  end

  def set_category_content
    @category_content = Badge
      .pluck(:title).map { |title| { category: t('solicitations.set_category_content.tags'), title: title } }
      .concat Solicitation.all_past_landing_options_slugs.map { |slug| { category: t('solicitations.set_category_content.options'), title: slug } }
      .concat Landing.pluck(:slug).map { |slug| { category: t('solicitations.set_category_content.landings'), title: slug } }
  end

  def count_solicitations
    @count_solicitations = Rails.cache.fetch(["count-solicitations", Solicitation.all, @territory]) do
      {
        without_feedbacks: ordered_solicitations.without_feedbacks.total_count,
          with_feedbacks: ordered_solicitations.with_feedbacks.total_count
      }
    end
  end

  def find_territories
    @territories = Territory.regions.order(:name)
    territory_id = territory_param || session[:territory]
    if territory_id.present?
      session[:territory] = territory_id
    else
      session.delete(:territory)
    end
  end

  def territory_param
    params.permit(:territory)[:territory]
  end
end
