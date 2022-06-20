module SolicitationModification
  class FormatParams
    def initialize(params)
      @params = params
      p @params
    end

    def call
      [
        formated_siret,
        formated_form_info,
        formated_institution_filters
      ].inject(&:merge)
    end

    private

    def formated_siret
      { siret: @params['siret'].presence }
    end

    def formated_form_info
      { form_info: @params.slice(*(Solicitation::FORM_INFO_KEYS).map(&:to_s)) }
    end

    def formated_institution_filters
      filter_params = @params.slice(*AdditionalSubjectQuestion.pluck(:key))
      filters = []
      formated_params = filter_params.each do |k, val|
        additional_subject_question = AdditionalSubjectQuestion.find_by(key: k)
        filters.push({ additional_subject_question_id: additional_subject_question.id, filter_value: val }) if additional_subject_question.present?
      end
      { institution_filters_attributes: filters }
    end
  end
end
