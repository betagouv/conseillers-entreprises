# frozen_string_literal: true

module UseCases
  class CreateSelectedAssistancesExperts
    class << self
      def perform(diagnosis, assistance_expert_ids)
        assistance_expert_ids.each do |id|
          diagnosed_need = DiagnosedNeed.of_diagnosis(diagnosis).of_assistance_expert_id(id).first
          next unless diagnosed_need
          SelectedAssistanceExpert.create assistances_experts_id: id, diagnosed_need: diagnosed_need
        end
      end
    end
  end
end
