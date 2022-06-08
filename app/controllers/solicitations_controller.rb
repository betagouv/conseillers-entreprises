class SolicitationsController < PagesController
  include IframePrefix

  layout 'solicitation_form', except: [:form_complete]

  def new
    solicitation_params = { landing_subject: @landing_subject }.merge(retrieve_solicitation_params)
    @solicitation = @landing.solicitations.new(solicitation_params)
    render :step_contact
  end

  def create
    sanitized_params = sanitize_params(solicitation_params).merge(retrieve_query_params)
    @solicitation = SolicitationModification::Create.new(sanitized_params).call!
    if @solicitation.persisted?
      redirect_to step_company_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :step_contact
    end
  end

  def update_step_contact
    update_solicitation_from_step(:step_contact, step_company_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire'))
  end

  def update_step_company
    update_solicitation_from_step(:step_company, step_description_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire'))
  end

  def step_description
    build_institution_filters
  end

  def update_step_description
    update_solicitation_from_step(:step_description, form_complete_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire'))
  end

  private

  def update_solicitation_from_step(step, redirect_path)
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      if step == :step_description
        @landing_subject = @solicitation.landing_subject
        CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
        @solicitation.delay.prepare_diagnosis(nil)
      end
      redirect_to redirect_path
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
              institution_filters_attributes: [:additional_subject_question_id, :filter_value])
  end

  def view_params
    params.permit(:landing_slug, :slug, :siret, *Solicitation::FORM_INFO_KEYS)
  end

  def retrieve_query_params
    # Les params ne passent pas en session dans les iframe, raison pour laquelle on check ici aussi les params de l'url
    saved_params = session[:solicitation_form_info] || {}
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS)
    saved_params.merge!(query_params)
    session.delete(:solicitation_form_info)
    { form_info: saved_params }
  end

  # Params envoyés dans les iframes pour pré-remplir le formulaire
  def retrieve_solicitation_params
    # On ne cherche que dans les params, car contexte d'iframe = pas de session
    query_params = view_params.slice(:siret)
    { siret: query_params['siret'] }
  end

  def build_institution_filters
    @solicitation.subject.additional_subject_questions.order(:position).each do |question|
      @solicitation.institution_filters.build(additional_subject_question: question)
    end
  end
end
