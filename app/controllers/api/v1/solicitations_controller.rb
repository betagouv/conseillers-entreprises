class Api::V1::SolicitationsController < Api::V1::BaseController
  def create
    begin
      @solicitation = SolicitationModification::CreateFromApi.new(sanitize_params(solicitation_params)).call!
      if @solicitation.persisted?
        render json: @solicitation, serializer: serializer, status: 200
      else
        errors = @solicitation.errors.map{ |e| { source: I18n.t(e.attribute, scope: [:activerecord, :attributes, :solicitation]), message: e.message } }
        render_error_payload(errors: errors, status: :unprocessable_entity)
      end
    rescue ActionController::ParameterMissing => e
      errors = [{ source: e.param, message: I18n.t('api_pde.errors.parameter_missing') }]
      render_error_payload(errors: errors, status: :bad_request)
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
end
