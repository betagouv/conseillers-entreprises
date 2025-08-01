class SolicitationsController < PagesController
  include IframePrefix

  layout 'solicitation_form'

  before_action :redirect_entreprendre_solicitations
  before_action :prevent_completed_solicitation_modification, except: [:new, :create, :form_complete]
  before_action :calculate_needs_count

  # Step contact
  #
  def new
    if @landing.is_paused?
      redirect_to({ controller: "landings/landings", action: "paused", landing_slug: @landing.slug })
    else
      with_step_data(step: :step_contact) do
        @solicitation = @landing.solicitations.new(landing_subject: @landing_subject)
        render :step_contact
      end
    end
  end

  def create
    with_step_data(step: :step_contact) do
      sanitized_params = sanitize_params(solicitation_params).merge(SolicitationModification::FormatQueryParams.new(query_params).call)
      @solicitation = SolicitationModification::Create.new(sanitized_params).call!
      if @solicitation.persisted?
        session.delete(:solicitation_form_info)
        redirect_to retrieve_company_step_path
      else
        flash.alert = @solicitation.errors.full_messages.to_sentence
        render :step_contact
      end
    end
  end

  def step_contact
    with_step_data { render :step_contact }
  end

  def update_step_contact
    with_step_data do
      @solicitation.go_to_step_company if @solicitation.may_go_to_step_company?
      if @solicitation.update(sanitize_params(solicitation_params))
        redirect_to retrieve_company_step_path
      else
        flash.alert = @solicitation.errors.full_messages.to_sentence
        render :step_contact
      end
    end
  end

  # Step company
  #
  def step_company
    with_step_data { render :step_company }
  end

  def step_company_search
    with_step_data(step: :step_company) { render :step_company_search }
  end

  def search_company
    with_step_data(step: :step_company) do
      # si l'utilisateur a utilisé l'autocompletion
      if siret_is_set?
        update_step_company_method
      elsif siren_is_set?
        redirect_path = { controller: "/solicitations", action: "search_facility", uuid: @solicitation.uuid, anchor: 'section-breadcrumbs' }.merge(search_params)
        redirect_to redirect_path and return
      else
        result = SearchFacility::Diffusable.new(search_params).from_full_text_or_siren
        respond_to do |format|
          format.html do
            if result[:error].blank?
              @companies = result[:items]
            else
              @error_message = result[:error]
              render 'step_company_search' and return
            end
          end
          format.json do
            render json: result.as_json
          end
        end
      end
    end
  end

  def search_facility
    with_step_data(step: :step_company) do
      result = SearchFacility::Diffusable.new(search_params).from_siren
      respond_to do |format|
        format.html do
          if result[:error].blank?
            @facilities = result[:items]
          else
            @error_message = result[:error]
            render 'step_company_search'
          end
        end
        format.json do
          render json: result.as_json
        end
      end
    end
  end

  def update_step_company
    with_step_data(step: :step_company) { update_step_company_method }
  end

  def update_step_company_method
    @solicitation.go_to_step_description if @solicitation.may_go_to_step_description?
    sanitized_params = sanitize_params(solicitation_params)
    if @solicitation.update(sanitized_params)
      redirect_to step_description_solicitation_path(@solicitation.uuid, anchor: 'section-breadcrumbs')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :step_company
    end
  end

  # Step description
  #
  def step_description
    with_step_data { build_subject_answers }
  end

  def update_step_description
    with_step_data do
      @solicitation.complete if @solicitation.may_complete?
      if @solicitation.update(sanitize_params(solicitation_params))
        ActiveRecord::Base.transaction do
          CreateAutomaticDiagnosisJob.perform_later(@solicitation.id)
          CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
          redirect_to form_complete_solicitation_path(@solicitation.uuid, anchor: 'section-breadcrumbs')
        end
      else
        flash.now.alert = @solicitation.errors.full_messages.to_sentence
        build_subject_answers if @solicitation.subject_answers.blank?
        render :step_description
      end
    end
  end

  def form_complete
    # TODO : mieux gérer les institutions en expérimentations (cf reject by slug)
    @displayable_institutions = @landing_subject.solicitable_institutions.with_solicitable_logo.where.not(slug: ['ademe']).order(:name)
    @opco = @landing_subject.solicitable_institutions.opco.any? ? @landing_subject.solicitable_institutions.opco.first : nil
    @mode_contact_privilegie = @solicitation.subject_answers.joins(:subject_question).find_by(subject_question: { key: 'mode_contact_privilegie' })&.filter_value || 'tel'
  end

  # Redirection vers la bonne étape de sollicitation
  # Utilisé par les emails de relance pour les sollicitations incomplètes
  def redirect_to_solicitation_step
    solicitation = Solicitation.find_by(uuid: params[:uuid])
    solicitation.update(relaunch: params.require(:relaunch)) if params[:relaunch].present?
    case solicitation.status
    when 'step_company'
      redirect_to step_company_search_solicitation_path(solicitation.uuid, anchor: 'section-breadcrumbs')
    # canceled : mail mauvaise qualité à modifier
    when 'step_description','canceled'
      redirect_to step_description_solicitation_path(solicitation.uuid, anchor: 'section-breadcrumbs')
    else
      redirect_to step_contact_solicitation_path(solicitation.uuid, anchor: 'section-breadcrumbs')
    end
  end

  private

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region, :status,
              *Solicitation::FIELD_TYPES.keys,
              subject_answers_attributes: [:id, :subject_question_id, :filter_value])
  end

  def search_params
    params.permit(:query)
  end

  def build_subject_answers
    @solicitation.subject.subject_questions.order(:position).each do |question|
      @solicitation.subject_answers.where(subject_question: question).first_or_initialize
    end
  end

  # on dirige vers la recherche de siret si le champs "company" est le siret
  def retrieve_company_step_path
    @solicitation.company_step_is_siret? ? step_company_search_solicitation_path(@solicitation.uuid, anchor: 'section-breadcrumbs') : step_company_solicitation_path(@solicitation.uuid, anchor: 'section-breadcrumbs')
  end

  def siret_is_set?
    siret_params_present? && solicitation_params[:siret].length == 14
  end

  def siren_is_set?
    siret_params_present? && solicitation_params[:siret].length == 9
  end

  def siret_params_present?
    params[:solicitation].present? && solicitation_params[:siret].present?
  end

  def with_step_data(step: nil)
    step ||= self.action_name.gsub('update_', '').to_sym
    set_steps(step)
    yield
  end

  def set_steps(current_view_step)
    # Cas des personnes retrouvant le lien alors que leur demande est gérée
    return if @solicitation&.step_unmodifiable?
    statuses = Solicitation.incompleted_statuses
    @step_data = {
      current_status: current_view_step,
      current_step: statuses.find_index(current_view_step.to_s) + 1,
      total_steps: statuses.count
    }
  end

  def prevent_completed_solicitation_modification
    if @solicitation&.step_unmodifiable?
      flash.alert = I18n.t('solicitations.creation_form.already_submitted_solicitation')
      redirect_to root_path
    end
  end

  # http://localhost:3000/aide-entreprise/accueil/demande/transport-mobilite/?mtm_campaign=entreprendre&mtm_kwd=F123
  def redirect_entreprendre_solicitations
    return unless ENV['FEATURE_REDIRECT_ENTREPRENDRE_TO_ROOT'] == 'true'
    if from_entreprendre_via_view_params || from_entreprendre_via_referer
      redirect_to root_path(query_params.merge(redirected: 'entreprendre'))
    end
  end

  def from_entreprendre_via_view_params
    QueryFromEntreprendre.new(campaign: query_params[:mtm_campaign], kwd: query_params[:mtm_kwd]).call && !(view_params[:redirected] == 'entreprendre')
  end

  def from_entreprendre_via_referer
    request.headers['referer'] == 'https://entreprendre.service-public.fr/'
  end

  def calculate_needs_count
    @needs_count = Rails.cache.fetch(['needs_count', @landing_subject.subject, Need.by_subject(@landing_subject.subject).size], expires_in: 1.hour) do
      Need
        .by_subject(@landing_subject.subject)
        .min_closed_at(1.year.ago..Date.today)
        .pluck(:id)
        .size
    end
  end
end
