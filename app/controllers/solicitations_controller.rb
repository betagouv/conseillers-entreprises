class SolicitationsController < PagesController
  include IframePrefix

  layout 'solicitation_form', except: [:form_complete]

  def new
    @solicitation = @landing.solicitations.new(landing_subject: @landing_subject)
    render :step_contact
  end

  def create
    sanitized_params = sanitize_params(solicitation_params).merge(SolicitationModification::FormatParams.new(query_params).call)
    @solicitation = SolicitationModification::Create.new(sanitized_params).call!
    if @solicitation.persisted?
      session.delete(:solicitation_form_info)
      redirect_to retrieve_company_step_path
    else
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render :step_contact
    end
  end

  def search_company
    @companies = SearchFacility.new(search_params).from_full_text_or_siren
    respond_to do |format|
      format.html
      format.json do
        render json: @companies.as_json
      end
    end
  end

  def search_facility
    @facilities = SearchFacility.new(search_params).from_siren
    respond_to do |format|
      format.html
      format.json do
        render json: @facilities.as_json
      end
    end
  end

  def update_step_contact
    update_solicitation_from_step(:step_contact, retrieve_company_step_path)
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
    @solicitation.siret_company_step? ? step_company_search_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire') : step_company_solicitation_path(@solicitation.uuid, anchor: 'section-formulaire')
  end
end
