# frozen_string_literal: true

module UseCases
  class CreateSelectedAssistancesExperts
    class << self
      def perform(diagnosis, assistance_expert_ids)
        assistance_expert_ids.each do |id|
          diagnosed_need = DiagnosedNeed.of_diagnosis(diagnosis).of_assistance_expert_id(id).first
          next unless diagnosed_need
          assistance_expert = AssistanceExpert.find id
          expert = assistance_expert.expert
          assistance = assistance_expert.assistance
          SelectedAssistanceExpert.create assistance_expert: assistance_expert,
                                          diagnosed_need: diagnosed_need,
                                          expert_full_name: expert.full_name,
                                          expert_institution_name: expert.institution.name,
                                          assistance_title: assistance.title
        end
      end
    end
  end
end
