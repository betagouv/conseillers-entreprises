class Conseiller::SolicitationsController < ApplicationController
  include PersistedSearch

  before_action :authorize_index_solicitation, :set_category_content, :count_solicitations, only: [:index, :processed, :canceled]
  before_action :find_solicitation, only: [:show, :update_status, :update_badges, :prepare_diagnosis]

  layout 'side_menu'

  def index
    @solicitations = ordered_solicitations(:in_progress)
    @facilities_histories = get_and_format_histories
    @solicitations.precompute_flags
    @status = t('solicitations.header.index')
  end

  def processed
    @solicitations = ordered_solicitations(:processed, :desc)
    @facilities_histories = get_and_format_histories
    @solicitations.precompute_flags
    @status = t('solicitations.header.processed')
    render :index
  end

  def canceled
    @solicitations = ordered_solicitations(:canceled, :desc)
    @facilities_histories = get_and_format_histories
    @solicitations.precompute_flags
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
    # 15594, 153737, 160857, 165126, 175892, 225798, 281417, 298046, 314208, 316929, 320735, 321929, 324536, 325698, 331062
    Solicitation
      .includes(:badges, :diagnosis, :facility, :needs,
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
    @solicitation = Solicitation.find(params.expect(:id))
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

  def get_and_format_histories
    emails, sirets, solicitations = prepare_emails_sirets_and_solicitations
    history = get_history_for_email_and_sirets(emails, sirets)

    # Group the history rows with the related solicitation
    result = history.each_with_object({}) do |history_row, result|
      solicitation_id = solicitations[history_row[:siret]] || solicitations[history_row[:email]]
      if solicitation_id.present?
        result[solicitation_id] ||= []
        result[solicitation_id] << history_row
      end
    end
    # and group the history rows of the same facility
    result.transform_values! do |h|
      h.group_by { |facility| facility[:facility_id] }.map do |facility_id, history_rows|
        { facility_id: facility_id, company_name: history_rows.first[:company_name], solicitation_completed_ats: history_rows.pluck(:solicitation_completed_at) }
      end
    end
  end

  # List the emails/siret related to @solicitations
  def prepare_emails_sirets_and_solicitations
    emails, sirets = [], []
    solicitations_hash = @solicitations.each_with_object({}) do |solicitation, hash|
      if solicitation.email.present?
        emails << solicitation.email
        hash[solicitation.email] = solicitation.id
      end
      if solicitation.siret.present?
        sirets << solicitation.siret
        hash[solicitation.siret] = solicitation.id
      end
    end
    sirets = (sirets.flatten | Facility.for_contacts(emails).pluck(:siret)).compact_blank

    [emails, sirets, solicitations_hash]
  end

  # Fetch the related history for the passed emails/sirets
  # returns an array of hashes with the following attributes
  # - email
  # - siret
  # - facility_id
  # - company_name
  # - solicitation_completed_at
  def get_history_for_email_and_sirets(emails, sirets)
    return Facility.none if emails.empty? && sirets.empty?

    Facility
      .select("DISTINCT ON (solicitations.id) COALESCE(contacts.email, '') AS email, facilities.siret, facilities.id as facility_id, companies.name AS company_name, solicitations.completed_at AS solicitation_completed_at")
      .joins(:company, diagnoses: :solicitation, company: :contacts)
      .where(diagnoses: { step: 5 })
      .where('contacts.email IN (?) OR facilities.siret IN (?)', emails, sirets)
      .to_a.map{ it.attributes.symbolize_keys }
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
