class SolicitationsController < PagesController
  include IframePrefix

  before_action :retrieve_landing_subject, only: [:new]
  before_action :find_solicitation, except: [:new, :create]
  before_action :retrieve_landing_subject_from_solicitation, only: [:step_contact, :update_step_contact, :form_complete]

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
      session[:solicitation_form_id] = @solicitation.id
      redirect_to step_company_solicitations_path(anchor: 'section-formulaire')
    else
      retrieve_landing_subject_from_solicitation
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :step_contact
    end
  end

  def update_step_contact
    update_solicitation_from_step(:step_contact)
  end

  def update_step_company
    update_solicitation_from_step(:step_company)
  end

  def update_step_description
    update_solicitation_from_step(:step_description)
  end

  private

  def update_solicitation_from_step(step)
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      if step == :step_description
        @landing_subject = @solicitation.landing_subject
        CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
        @solicitation.delay.prepare_diagnosis(nil)
        redirect_to form_complete_solicitations_path(anchor: 'section-formulaire')
      else
        redirect_to polymorphic_path([@solicitation.status.to_sym, Solicitation], anchor: 'section-formulaire')
      end
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render step
    end
  end

  def find_solicitation
    solicitation_id = session[:solicitation_form_id]
    @solicitation = Solicitation.find(solicitation_id)
    redirect_to root_path if @solicitation.nil?
  end

  def retrieve_landing_subject
    @landing_subject = LandingSubject.not_archived.find(params[:landing_subject_id])
    @landing = Landing.not_archived.find(params[:landing_id])
    redirect_to root_path, status: :moved_permanently if (@landing_subject.nil? || @landing.nil?)
  end

  def retrieve_landing_subject_from_solicitation
    @landing = @solicitation.landing
    @landing_subject = @solicitation.landing_subject
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region, :status,
              *Solicitation::FIELD_TYPES.keys)
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
end
