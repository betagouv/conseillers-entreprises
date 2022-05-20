class SolicitationsController < PagesController
  before_action :retrieve_landing_subject, only: [:new]
  before_action :find_solicitation, except: [:new, :create]

  layout 'solicitation_form', except: [:form_complete]

  def new
    solicitation_params = { landing_subject: @landing_subject }.merge(retrieve_solicitation_params)
    @solicitation = @landing.solicitations.new(solicitation_params)
    render :form_contact
  end

  def create
    sanitized_params = sanitize_params(solicitation_params).merge(retrieve_query_params)
    @solicitation = SolicitationModification::Create.new(sanitized_params).call!
    if @solicitation.persisted?
      session[:solicitation_form_id] = @solicitation.id
      redirect_to form_company_solicitations_path(anchor: 'section-formulaire')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_contact
    end
  end

  def form_contact
    @landing = @solicitation.landing
    @landing_subject = @solicitation.landing_subject

    render :form_contact
  end

  def update_form_contact
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      redirect_to form_company_solicitations_path(anchor: 'section-formulaire')
    else
      @landing = @solicitation.landing
      @landing_subject = @solicitation.landing_subject
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_contact
    end
  end

  def update_form_company
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      redirect_to form_description_solicitations_path(anchor: 'section-formulaire')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_company
    end
  end

  def update_form_description
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      ab_finished(:solicitation_form)
      CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
      @solicitation.delay.prepare_diagnosis(nil)
      redirect_to form_complete_solicitations_path(anchor: 'section-formulaire')
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_description
    end
  end

  private

  def find_solicitation
    solicitation_id = session[:solicitation_form_id]
    @solicitation = Solicitation.find(solicitation_id)
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

  def retrieve_landing_subject
    @landing_subject = LandingSubject.not_archived.find(params[:landing_subject_id])
    @landing = Landing.not_archived.find(params[:landing_id])
    redirect_to root_path, status: :moved_permanently if (@landing_subject.nil? || @landing.nil?)
  end

  # Params envoyés dans les iframes pour pré-remplir le formulaire
  def retrieve_solicitation_params
    # On ne cherche que dans les params, car contexte d'iframe = pas de session
    query_params = view_params.slice(:siret)
    { siret: query_params['siret'] }
  end
end
