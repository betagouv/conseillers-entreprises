class Conseiller::SolicitationsController < ApplicationController
  before_action :authorize_index_solicitation, :persist_search_params, :set_category_content, :count_solicitations, only: [:index, :processed, :canceled]
  before_action :find_solicitation, only: [:show, :update_status, :update_badges, :prepare_diagnosis, :ban_facility]

  layout 'side_menu'

  def index
    @solicitations = ordered_solicitations(:in_progress)
    @facilities = get_and_format_facilities
    @status = t('solicitations.header.index')
  end

  def processed
    @solicitations = ordered_solicitations(:processed)
    @facilities = get_and_format_facilities
    @status = t('solicitations.header.processed')
    render :index
  end

  def canceled
    @solicitations = ordered_solicitations(:canceled)
    @facilities = get_and_format_facilities
    @status = t('solicitations.header.canceled')
    render :index
  end

  def show
    authorize @solicitation
    reset_session
    nb_per_page = Solicitation.page(1).limit_value
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
    authorize @solicitation, :update?
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
    Solicitation
      .includes(:badge_badgeables, :badges, :landing, :diagnosis, :facility, feedbacks: { user: :antenne }, landing_subject: :subject, institution: :logo)
      .where(status: status)
      .apply_filters(sol_search_params)
      .order(:completed_at)
      .page(params[:page])
  end

  def sol_search_params
    session[:sol_search_params]&.with_indifferent_access
  end
  helper_method :sol_search_params

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def persist_search_params
    session[:sol_search_params] ||= {}
    search_params = params.slice(:omnisearch, :by_region).permit!
    if params[:reset_query].present?
      reset_session
    else
      session[:sol_search_params] = session[:sol_search_params].merge(search_params)
    end
  end

  def reset_session
    session[:sol_search_params] = {}
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

  def get_and_format_facilities
    emails, sirets, solicitations = prepare_emails_sirets_and_solicitations
    facilities = get_facilities_for_email_and_sirets(emails, sirets)
    return facilities.each_with_object({}) do |facility, hash|
      solicitation_id = solicitations[facility.siret] || solicitations[facility.contact_email]
      if solicitation_id.present?
        hash[solicitation_id] = [] if hash[solicitation_id].nil?
        hash[solicitation_id] << { id: facility.id, company_name: facility.company_name }
      end
    end
  end

  # Facilities en lien avec les solicitations
  # Préparation des données dans le controller pour améliorer les performances
  def prepare_emails_sirets_and_solicitations
    emails, sirets = [], []
    solicitations_hash = @solicitations.each_with_object({}) do |solicitation, hash|
      emails << solicitation.email
      sirets << solicitation.siret
      hash[solicitation.siret] = solicitation.id
      hash[solicitation.email] = solicitation.id
    end
    sirets = (sirets.flatten | Facility.for_contacts(emails).pluck(:siret)).compact_blank

    return emails, sirets, solicitations_hash
  end

  def get_facilities_for_email_and_sirets(emails, sirets)
    Facility
      .select('facilities.*, companies.name AS company_name, contacts.email AS contact_email')
      .joins(:diagnoses, company: :contacts)
      .where(diagnoses: { step: 5 })
      .where(contacts: { email: emails })
      .or(Facility.where(diagnoses: { step: 5 }).where(siret: sirets))
      .distinct
  end
end
