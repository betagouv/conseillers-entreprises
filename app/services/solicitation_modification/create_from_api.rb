module SolicitationModification
  class CreateFromApi < Base
    def format_params(params)
      return params if params[:questions_additionnelles].nil?
      formatted_questions_additionnelles = params.delete(:questions_additionnelles).map{ |question| { additional_subject_question_id: question['question_id'], filter_value: question['answer'] } }
      params
        .merge(institution_filters_attributes: formatted_questions_additionnelles)
    end
  end
end
