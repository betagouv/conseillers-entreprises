class SolicitationsController < PagesController
  include IframePrefix

  layout 'solicitation_form', except: [:form_complete]

  before_action :set_steps

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
    update_step_description: :step_description
  }

  def new
    @solicitation = @landing.solicitations.new(landing_subject: @landing_subject)
    render current_template
  end

  def create
    sanitized_params = sanitize_params(solicitation_params).merge(SolicitationModification::FormatParams.new(query_params).call)
    @solicitation = SolicitationModification::Create.new(sanitized_params).call!
    if @solicitation.persisted?
      redirect_to retrieve_company_step_path
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render current_template
    end
  end

  def search_company
    # si l'utilisateur a utilisé l'autocompletion
    if siret_is_set?
      update_solicitation_from_step(current_template, step_description_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire'))
    elsif siren_is_set?
      redirect_path = { controller: "/solicitations", action: "search_facility", uuid: @solicitation.uuid, anchor: 'section-formulaire' }.merge(search_params)
      redirect_to redirect_path and return
    else
      result = SearchFacility.new(search_params).from_full_text_or_siren
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
    result = SearchFacility.new(search_params).from_siren
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

  def update_step_contact
    update_solicitation_from_step(current_template, retrieve_company_step_path)
  end

  def update_step_company
    update_solicitation_from_step(current_template, step_description_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire'))
  end

  def step_description
    build_institution_filters
  end

  def update_step_description
    update_solicitation_from_step(current_template, form_complete_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire'))
  end

  # Redirection vers la bonne étape de sollicitation
  # Utilisé par les emails de relance pour les sollicitations incomplètes
  def redirect_to_solicitation_step
    solicitation = Solicitation.find_by(uuid: params[:uuid])
    solicitation.update(relaunch: params.require(:relaunch))
    case solicitation.status
    when 'step_company'
      redirect_to step_company_search_solicitation_path(solicitation.uuid, anchor: 'section-formulaire')
    when 'step_description'
      redirect_to step_description_solicitation_path(solicitation.uuid, anchor: 'section-formulaire')
    end
  end

  private

  def update_solicitation_from_step(step, next_step_path)
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      if step == :step_description
        @landing_subject = @solicitation.landing_subject
        CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
        @solicitation.delay.prepare_diagnosis(nil)
      end
      redirect_to next_step_path
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      build_institution_filters if step == :step_description
      render step
    end
  end

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
    TEMPLATES[self.action_name.to_sym]
  end

  def set_steps
    current_status = current_template
    @step_data = {
      current_status: current_status,
      current_step: Solicitation.incompleted_statuses.find_index(current_status.to_s) + 1,
      total_steps: Solicitation.incompleted_statuses.count
    }
  end
end
