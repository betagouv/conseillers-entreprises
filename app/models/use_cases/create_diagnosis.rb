# frozen_string_literal: true

module UseCases
  class CreateDiagnosis
    class << self
      def create_with_params(params)
        diagnosis = Diagnosis.create visit_id: params['visit_id']
        return diagnosis unless params['diagnosed_needs']
        params['diagnosed_needs'].each do |need|
          next unless need['selected'] == 'on'
          DiagnosedNeed.create diagnosis: diagnosis,
                               question_label: need['question_label'],
                               question_id: need['question_id']
        end
        diagnosis
      end
    end
  end
end
