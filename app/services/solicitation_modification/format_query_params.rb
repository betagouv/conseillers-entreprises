module SolicitationModification
  class FormatQueryParams
    def initialize(params)
      @params = params
    end

    def call
      [
        formated_siret,
        formated_form_info,
        formated_subject_answers
      ].reduce(&:merge)
    end

    private

    def formated_siret
      { siret: @params['siret'].presence }
    end

    def formated_form_info
      { form_info: @params.slice(*(Solicitation::FORM_INFO_KEYS).map(&:to_s)) }
    end

    def formated_subject_answers
      filter_params = @params.slice(*SubjectQuestion.pluck(:key))
      filters = []
      formated_params = filter_params.each do |k, val|
        subject_question = SubjectQuestion.find_by(key: k)
        filters.push({ subject_question_id: subject_question.id, filter_value: val }) if subject_question.present?
      end
      { subject_answers_attributes: filters }
    end
  end
end
