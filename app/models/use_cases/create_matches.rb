# frozen_string_literal: true

module UseCases
  class CreateMatches
  class << self
      def perform(diagnosis, assistance_expert_ids)
        assistances_experts = assistances_experts_for_diagnosis(diagnosis.id, assistance_expert_ids)
        assistances_experts.each do |assistance_expert|
          diagnosed_need = assistance_expert.assistance.question.diagnosed_needs.first
          if !diagnosed_need
            next
          end
          expert = assistance_expert.expert
          assistance = assistance_expert.assistance
          Match.create assistance_expert: assistance_expert, diagnosed_need: diagnosed_need,
                       expert_full_name: expert.full_name, assistance_title: assistance.title,
                       expert_institution_name: expert.institution.name
        end
      end

      private

      def assistances_experts_for_diagnosis(diagnosis_id, assistance_expert_ids)
        associations = [:expert, :assistance, expert: :institution, assistance: [
          :question, question: [:diagnosed_needs, diagnosed_needs: :diagnosis]
        ]]
        condition = { assistances: { questions: { diagnosed_needs: { diagnoses: { id: diagnosis_id } } } } }
        AssistanceExpert.joins(associations).includes(associations).where(condition).where(id: assistance_expert_ids)
      end
    end
  end
end
