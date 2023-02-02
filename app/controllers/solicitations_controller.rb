class SolicitationsController < PagesController
  include IframePrefix

  layout 'solicitation_form'

  before_action :set_steps, except: [:form_complete]
  before_action :prevent_completed_solicitation_modification, except: [:new, :create, :form_complete]

  # On peut naviguer dans le formulaire, donc on ne peut se fier au status de la solicitation en cours
  # Ex : sol statut description, mais qui revient à contact_step
  TEMPLATES = {
    new: :step_contact,
    create: :step_contact,
    step_contact: :step_contact,
    update_step_contact: :step_contact,
    search_company: :step_company,
    search_facility: :step_company,
    step_company: :step_company,
    step_company_search: :step_company,
    update_step_company: :step_company,
    step_description: :step_description,
    update_step_description: :step_description,
  }

  # Step contact
  #
  def new
    @solicitation = @landing.solicitations.new(landing_subject: @landing_subject)
    render :step_contact
  end

  def create
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

  def update_step_contact
    @solicitation.go_to_step_company if @solicitation.may_go_to_step_company?
    if @solicitation.update(sanitize_params(solicitation_params))
      redirect_to retrieve_company_step_path
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :step_contact
    end
  end

  # Step company
  #
  def search_company
    # si l'utilisateur a utilisé l'autocompletion
    if siret_is_set?
      update_step_company_method
    elsif siren_is_set?
      redirect_path = { controller: "/solicitations", action: "search_facility", uuid: @solicitation.uuid, anchor: 'section-formulaire' }.merge(search_params)
      redirect_to redirect_path and return
    else
      result = SearchFacility::NonDiffusable.new(search_params).from_full_text_or_siren
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

  def search_facility
    result = SearchFacility::NonDiffusable.new(search_params).from_siren
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

  def update_step_company
    update_step_company_method
  end

  def update_step_company_method
    @solicitation.go_to_step_description if @solicitation.may_go_to_step_description?
    sanitized_params = sanitize_params(solicitation_params)
    if @solicitation.update(sanitized_params)
      redirect_to step_description_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :step_company
    end
  end

  # Step description
  #
  def step_description
    build_institution_filters if @solicitation.institution_filters.blank?
  end

  def update_step_description
    @solicitation.complete if @solicitation.may_complete?
    if @solicitation.update(sanitize_params(solicitation_params))
      @solicitation.delay.prepare_diagnosis(nil)
      CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
      redirect_to form_complete_solicitation_path(@solicitation.uuid)
    else
      flash.now.alert = @solicitation.errors.full_messages.to_sentence
      build_institution_filters if @solicitation.institution_filters.blank?
      render :step_description
    end
  end

  def form_complete
    @displayable_institutions = @landing_subject.solicitable_institutions.with_logo.order(:name)
    @opco = @landing_subject.solicitable_institutions.opco.any? ? @landing_subject.solicitable_institutions.opco.first : nil
  end

  # Redirection vers la bonne étape de sollicitation
  # Utilisé par les emails de relance pour les sollicitations incomplètes
  def redirect_to_solicitation_step
    solicitation = Solicitation.find_by(uuid: params[:uuid])
    solicitation.update(relaunch: params.require(:relaunch)) if params[:relaunch].present?
    case solicitation.status
    when 'step_company'
      redirect_to step_company_search_solicitation_path(solicitation.uuid, anchor: 'section-formulaire')
    when 'step_description'
      redirect_to step_description_solicitation_path(solicitation.uuid, anchor: 'section-formulaire')
    else
      redirect_to step_contact_solicitation_path(solicitation.uuid, anchor: 'section-formulaire')
    end
  end

  private

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region, :status,
              *Solicitation::FIELD_TYPES.keys,
              institution_filters_attributes: [:id, :additional_subject_question_id, :filter_value])
  end

  def search_params
    params.permit(:query)
  end

  def build_institution_filters
    @solicitation.subject.additional_subject_questions.order(:position).each do |question|
      @solicitation.institution_filters.where(additional_subject_question: question).first_or_initialize
    end
  end

  # on dirige vers la recherche de siret si le champs "company" est le siret
  def retrieve_company_step_path
    @solicitation.company_step_is_siret? ? step_company_search_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire') : step_company_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire')
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

  def current_template
    if self.action_name == 'redirect_to_solicitation_step'
      @solicitation.status.to_sym
    else
      TEMPLATES[self.action_name.to_sym]
    end
  end

  def set_steps
    # Cas des personnes retrouvant le lien alors que leur demande est gérée
    return if @solicitation.step_complete?
    current_status = current_template
    statuses = Solicitation.incompleted_statuses
    @step_data = {
      current_status: current_status,
      current_step: statuses.find_index(current_status.to_s) + 1,
      total_steps: statuses.count
    }
  end

  def prevent_completed_solicitation_modification
    if @solicitation.step_complete?
      flash.alert = I18n.t('solicitations.creation_form.already_submitted_solicitation')
      redirect_to root_path
    end
  end
end
