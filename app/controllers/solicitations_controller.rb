class SolicitationsController < PagesController
  before_action :find_solicitation, except: [:create]

  layout 'solicitation_form', except: [:form_complete]

  def create
    sanitized_params = sanitize_params(solicitation_params).merge(retrieve_query_params)
    @solicitation = SolicitationModification::Create.new(sanitized_params).call!
    if @solicitation.persisted?
      redirect_to form_company_solicitation_path(@solicitation)
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_contact
    end
  end

  def form_contact
    @landing = @solicitation.landing
    @landing_subject = @solicitation.landing_subject
    @step = :contact
    render 'solicitations/form_contact'
  end

  def update_form_contact
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      redirect_to form_company_solicitation_path(@solicitation)
    else
      @step = :contact
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_contact
    end
  end

  def form_company
    @step = :company
  end

  def update_form_company
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      redirect_to form_description_solicitation_path(@solicitation)
    else
      @step = :company
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_company
    end
  end

  def form_description
    @step = :description
  end

  def update_form_description
    sanitized_params = sanitize_params(solicitation_params)
    @solicitation = SolicitationModification::Update.new(@solicitation, sanitized_params).call!
    if @solicitation.errors.empty?
      CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
      @solicitation.delay.prepare_diagnosis(nil)
      ab_finished(:solicitation_form)
      redirect_to form_complete_solicitation_path(@solicitation)
    else
      @step = :description
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :form_description
    end
  end

  private

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region, :step,
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
end
