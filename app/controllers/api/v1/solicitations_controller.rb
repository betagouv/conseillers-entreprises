class Api::V1::SolicitationsController < Api::V1::BaseController
  def create
    begin
      params = format_params(sanitize_params(solicitation_params))
      @solicitation = Solicitation.new(params)
      if @solicitation.complete!
        render json: @solicitation, serializer: serializer, status: 200
      else
        errors = @solicitation.errors.map{ |e| { source: I18n.t(e.attribute, scope: [:activerecord, :attributes, :solicitation]), message: e.message } }
        render_error_payload(errors: errors, status: :unprocessable_entity)
      end
    rescue ActionController::ParameterMissing => e
      errors = [{ source: e.param, message: I18n.t('api_pde.errors.parameter_missing') }]
      render_error_payload(errors: errors, status: :bad_request)
    rescue ActionDispatch::Http::Parameters::ParseError => e
      parsing_error(e)
    rescue Exception => e
      errors = [{ source: e.class.name, message: e.message }]
      render_error_payload(errors: errors, status: :unprocessable_entity)

      Sentry.capture_exception(e)
    end
  end

  private

  def serializer
    Api::V1::SolicitationLogoSerializer
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region, :api_calling_url,
              *Solicitation::FIELD_TYPES.keys,
              questions_additionnelles: [:question_id, :answer]).merge(status: :step_description)
  end

  def format_params(params)
    return params if params[:questions_additionnelles].nil?
    formatted_questions_additionnelles = params.delete(:questions_additionnelles).map{ |question| { additional_subject_question_id: question['question_id'], filter_value: question['answer'] } }
    fixed_questions_additionnelles = fix_questions_additionnelles(params, formatted_questions_additionnelles)
    params
      .merge(institution_filters_attributes: fixed_questions_additionnelles)
  end

  # Fix temporaire le temps que le bug partenaire soit réparé, et qu'on puisse mettre en place + de validations
  def fix_questions_additionnelles(params, formatted_questions_additionnelles)
    landing_subject_id = params[:landing_subject_id]
    subject = LandingSubject.find(landing_subject_id).subject

    formatted_questions_additionnelles.each_with_index do |hash, index|
      true_additional_subject_question = AdditionalSubjectQuestion.find_by(subject_id: subject.id, position: index + 1)
      hash[:additional_subject_question_id] = true_additional_subject_question.id
    end
    formatted_questions_additionnelles
  end
end
