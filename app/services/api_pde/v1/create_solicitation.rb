class ApiPde::V1::CreateSolicitation < ApiPde::V1::Base
  def call
    api_transaction do
      create_solicitation!
      OpenStruct.new(success?: true,
                     solicitation:  @solicitation,
                     errors: nil)
    end
  end

  private # ==============================================

  def create_solicitation!
    @solicitation = SolicitationModification::Create.new(solicitation_params).call!
  end

  def solicitation_params
    params.permit(
      :landing_id, :landing_subject_id, :description, :code_region, :api_calling_url,
      *Solicitation::FIELD_TYPES.keys
    ).merge(status: :step_description, institution_filters_attributes: institution_filters_params)
  end

  def institution_filters_params
    raw_params = params.require(:questions_additionnelles)
    raw_params.map do |question|
      { additional_subject_question_id: question['question_id'], filter_value: question['answer'] }
    end
  end
end
