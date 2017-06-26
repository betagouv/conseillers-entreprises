# frozen_string_literal: true

module UseCases
  class CreateDiagnosis
    class << self
      def create_with_params(params)
        diagnosis = Diagnosis.create visit_id: params['visit_id']
        return diagnosis unless params['diagnosed_needs']
        create_needs(diagnosis: diagnosis, needs_json_array: params['diagnosed_needs'])
        diagnosis
      end

      def create_needs(needs_json_array:, diagnosis:)
        needs_json_array.each do |need|
          next unless need['selected'] == 'on'
          DiagnosedNeed.create(
            diagnosis: diagnosis,
            question_label: need['question_label'],
            question_id: need['question_id']
          )
        end
      end
    end
  end
end
