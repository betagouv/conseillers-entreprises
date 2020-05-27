class SolicitationsController < ApplicationController
  before_action :find_solicitation, only: [:show, :update_status, :update_badges]
  before_action :authorize_index_solicitation, only: [:index, :processed, :canceled]
  before_action :authorize_update_solicitation, only: [:update_status]
  before_action :set_category_content, only: %i[index processed canceled]

  def index
    @solicitations = ordered_solicitations.status_in_progress
  end

  def processed
    @solicitations = ordered_solicitations.status_processed
    render :index
  end

  def canceled
    @solicitations = ordered_solicitations.status_canceled
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
    done = Solicitation.human_attribute_name("statuses_done.#{status}", count: 1)
    flash.notice = "#{@solicitation} #{done}"
    render 'remove'
  end

  def update_badges
    @solicitation.update(params.require(:solicitation).permit(badge_ids: []))
  end

  private

  def ordered_solicitations
    Solicitation.order(updated_at: :desc).page(params[:page]).omnisearch(params[:query])
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
end
