class Conseiller::SolicitationsController < ApplicationController
  include PersistedSearch

  before_action :authorize_index_solicitation, :set_category_content, :count_solicitations, only: [:index, :processed, :canceled]
  before_action :find_solicitation, only: [:show, :update_status, :update_badges, :prepare_diagnosis]

  layout 'side_menu'

  def index
    @solicitations = ordered_solicitations(:in_progress)
    @facilities = get_and_format_facilities
    @status = t('solicitations.header.index')
  end

  def processed
    @solicitations = ordered_solicitations(:processed, :desc)
    @facilities = get_and_format_facilities
    @status = t('solicitations.header.processed')
    render :index
  end

  def canceled
    @solicitations = ordered_solicitations(:canceled, :desc)
    @facilities = get_and_format_facilities
    @status = t('solicitations.header.canceled')
    render :index
  end

  def show
    authorize @solicitation
    reset_session
    nb_per_page = Solicitation.page(1).limit_value
    anchor = "solicitation_#{@solicitation.id}"

    case @solicitation.status
    when 'canceled'
      page = calculate_page_number(:status_canceled, @solicitation.completed_at, nb_per_page, :desc)
      redirect_to canceled_conseiller_solicitations_path(anchor: anchor, page: page)
    when 'processed'
      page = calculate_page_number(:status_processed, @solicitation.completed_at, nb_per_page, :desc)
      redirect_to processed_conseiller_solicitations_path(anchor: anchor, page: page)
    else
      page = calculate_page_number(:status_in_progress, @solicitation.completed_at, nb_per_page, :asc)
      redirect_to conseiller_solicitations_path(anchor: anchor, page: page)
    end
  end

  def update_status
    authorize @solicitation, :update?
    status = params[:status]
    @solicitation.update(status: status)
    if @solicitation.valid?
      done = Solicitation.human_attribute_value(:status, status, context: :done, count: 1)
      flash.notice = "#{@solicitation} #{done}"
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@solicitation) }
        format.html         { redirect_back_or_to conseiller_solicitations_path }
      end
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      redirect_to [:conseiller, @solicitation]
    end
  end

  def update_badges
    badges_params = params.expect(solicitation: [badge_ids: []])
    if @solicitation.valid?
      @solicitation.update(badges_params)
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      respond_to do |format|
        format.js
        format.html { redirect_to [:conseiller, @solicitation] }
      end
    end
  end

  def prepare_diagnosis
    diagnosis = DiagnosisCreation::CreateAutomaticDiagnosis.new(@solicitation, current_user).call
    if diagnosis
      redirect_to [:conseiller, diagnosis]
    else
      flash.alert = @solicitation.prepare_diagnosis_errors_to_s.to_sentence
      redirect_to [:conseiller, @solicitation]
    end
  end

  def mark_as_spam
    @solicitation = Solicitation.find(params.permit(:id)[:id])
    authorize @solicitation, :mark_as_spam?
    @solicitation.mark_as_spam
    redirect_to conseiller_solicitations_path, notice: t('solicitations.mark_as_spam')
  end

  private

  def ordered_solicitations(status, order = :asc)
    Solicitation
      .includes(:badges, :diagnosis, :facility,
        feedbacks: { user: :antenne },
        landing_subject: :subject,
        subject_answers: :subject_question)
      .where(status: status)
      .apply_filters(index_search_params)
      .order(completed_at: order)
      .page(params[:page])
  end

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
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

  def search_session_key
    :sol_search_params
  end

  def search_fields
    [:omnisearch, :by_cooperation, :by_region]
  end

  def territory_options_complement
    [ t('helpers.solicitation.uncategorisable_label'), t('helpers.solicitation.uncategorisable_value') ]
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
      hash[solicitation.email] = solicitation.id
      unless solicitation.siret.nil?
        sirets << solicitation.siret
        hash[solicitation.siret] = solicitation.id
      end
    end
    sirets = (sirets.flatten | Facility.for_contacts(emails).pluck(:siret)).compact_blank

    return emails, sirets, solicitations_hash
  end

  def get_facilities_for_email_and_sirets(emails, sirets)
    return Facility.none if emails.empty? && sirets.empty?

    Facility
      .select('DISTINCT facilities.id, facilities.*, companies.name AS company_name, COALESCE(contacts.email, \'\') AS contact_email')
      .joins(:company, :diagnoses, company: :contacts)
      .where(diagnoses: { step: 5 })
      .where('contacts.email IN (?) OR facilities.siret IN (?)', emails, sirets)
  end

  def calculate_page_number(status_scope, completed_at, nb_per_page, order = :asc)
    count = if order == :desc
      # Pour un ordre DESC, on compte les éléments après la date (plus récents)
      Solicitation.public_send(status_scope).where(completed_at: completed_at..).count
    else
      # Pour un ordre ASC, on compte les éléments avant la date (plus anciens)
      Solicitation.public_send(status_scope).where(completed_at: ...completed_at).count
    end

    (count / nb_per_page) + 1
  end
end
