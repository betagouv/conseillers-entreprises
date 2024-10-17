class Api::V1::SolicitationsController < Api::V1::BaseController
  def create
    begin
      params = format_params(sanitize_params(solicitation_params))
      @solicitation = Solicitation.new(params)
      if @solicitation.complete!
        ActiveRecord::Base.transaction do
          CreateAutomaticDiagnosisJob.perform_later(@solicitation.id)
          CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
          render json: @solicitation, serializer: serializer, status: 200
        end
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

  # TODO: remplacer api_calling_url par origin_url
  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region, :api_calling_url, :origin_url,
              *Solicitation::FIELD_TYPES.keys,
              questions_additionnelles: [:question_id, :answer]).merge(status: :step_description)
  end

  def format_params(params)
    params = params.merge(origin_url: params[:api_calling_url]) if params[:origin_url].blank?
    return params if params[:questions_additionnelles].nil?
    formatted_questions_additionnelles = params.delete(:questions_additionnelles).map{ |question| { subject_question_id: question['question_id'], filter_value: question['answer'] } }
    params.merge(subject_answers_attributes: formatted_questions_additionnelles)
  end
end
