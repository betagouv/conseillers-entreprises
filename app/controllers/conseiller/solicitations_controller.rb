class Conseiller::SolicitationsController < ApplicationController
  include TerritoryFiltrable

  before_action :find_solicitation, only: [:show, :update_status, :update_badges, :prepare_diagnosis, :ban_facility]
  before_action :authorize_index_solicitation, :set_category_content, :setup_territory_filters, :count_solicitations, only: [:index, :processed, :canceled]
  before_action :authorize_update_solicitation, only: [:update_status]

  layout 'side_menu'

  def index
    @solicitations = ordered_solicitations(:in_progress)
    @status = t('solicitations.header.index')
  end

  def processed
    @solicitations = ordered_solicitations(:processed)
    @status = t('solicitations.header.processed')
    render :index
  end

  def canceled
    @solicitations = ordered_solicitations(:canceled)
    @status = t('solicitations.header.canceled')
    render :index
  end

  def show
    authorize @solicitation
    nb_per_page = Solicitation.page(1).limit_value
    session.delete(territory_session_param)
    case @solicitation.status
    when 'canceled'
      page = (Solicitation.status_canceled.where('completed_at < ?', @solicitation.completed_at).count / nb_per_page) + 1
      redirect_to canceled_conseiller_solicitations_path(anchor: @solicitation.id, page: page)
    when 'processed'
      page = (Solicitation.status_processed.where('completed_at < ?', @solicitation.completed_at).count / nb_per_page) + 1
      redirect_to processed_conseiller_solicitations_path(anchor: @solicitation.id, page: page)
    else
      page = (Solicitation.status_in_progress.where('completed_at < ?', @solicitation.completed_at).count / nb_per_page) + 1
      redirect_to conseiller_solicitations_path(anchor: @solicitation.id, page: page)
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
      redirect_to [:conseiller, @solicitation]
    end
  end

  def update_badges
    badges_params = params.require(:solicitation).permit(badge_ids: [])
    if @solicitation.valid?
      @solicitation.update(badges_params)
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      redirect_to [:conseiller, @solicitation]
    end
  end

  def prepare_diagnosis
    diagnosis = @solicitation.prepare_diagnosis(current_user)
    if diagnosis
      redirect_to diagnosis
    else
      flash.alert = @solicitation.prepare_diagnosis_errors.full_messages.to_sentence
      redirect_to [:conseiller, @solicitation]
    end
  end

  def ban_facility
    if Ban::Solicitation.new(@solicitation).toggle
      flash.notice = @solicitation.banned? ? t('.marked_as_banned') : t('.marked_as_unbanned')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
    end
    redirect_to action: :index
  end

  private

  def ordered_solicitations(status)
    solicitations = Solicitation.where(status: status).order(:completed_at)
    solicitations = solicitations.by_possible_region(territory_id) if territory_id.present?
    solicitations.omnisearch(params[:query]).distinct
      .includes(:badge_badgeables, :badges, :landing, :diagnosis, :facility, feedbacks: { user: :antenne }, landing_subject: :subject, institution: :logo).page(params[:page])
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
      .concat LandingSubject.pluck(:slug).map { |slug| { category: t('solicitations.set_category_content.subjects'), title: slug } }
      .concat Landing.pluck(:slug).map { |slug| { category: t('solicitations.set_category_content.landings'), title: slug } }
  end

  def count_solicitations
    # ces count varient très souvent (dès que les bizdev travaillent sur les solicitations),
    # le cache n'avait pas beaucoup de sens ici
    @count_solicitations =
      {
        in_progress: ordered_solicitations(:in_progress).total_count
      }
  end

  # nom de variable spécifique pour ne pas parasiter les autres filtres région
  def territory_session_param
    :s_territory
  end
end
