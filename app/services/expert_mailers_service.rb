# frozen_string_literal: true

class ExpertMailersService
  class << self
    def send_assistances_email(advisor:, diagnosis:, assistance_expert_ids:)
      assistances_experts = retrieve_assistances_experts(assistance_expert_ids)
      questions_grouped_by_experts = questions_grouped_by_experts(assistances_experts, diagnosis)
      questions_grouped_by_experts.each { |expert_hash| notify_expert(expert_hash, advisor, diagnosis) }
    end

    def filter_assistances_experts(assistances_experts_hash)
      assistances_experts_hash.select { |_key, value| value == '1' }.keys.map(&:to_i)
    end

    def retrieve_assistances_experts(assistance_expert_ids)
      associations = [:expert, :assistance, expert: :institution, assistance: :question]
      AssistanceExpert.where(id: assistance_expert_ids).joins(associations).includes(associations)
    end

    def questions_grouped_by_experts(assistances_experts, diagnosis)
      questions_grouped_by_experts = {}
      assistances_experts.each do |assistance_expert|
        expert_id = assistance_expert.expert_id
        unless questions_grouped_by_experts[expert_id]
          questions_grouped_by_experts[expert_id] = init_questions_grouped_by_experts_for_ae(assistance_expert)
        end
        questions_grouped_by_experts[expert_id][:questions_with_needs_description] <<
          questions_with_needs_description_hash(assistance_expert, diagnosis)
      end
      questions_grouped_by_experts.values
    end

    def init_questions_grouped_by_experts_for_ae(assistance_expert)
      {
        expert: assistance_expert.expert,
        questions_with_needs_description: []
      }
    end

    def questions_with_needs_description_hash(assistance_expert, diagnosis)
      question = assistance_expert.assistance.question
      need_description = DiagnosedNeed.of_diagnosis(diagnosis).of_question(question).first.content
      {
        question: question,
        need_description: need_description
      }
    end

    def notify_expert(expert_hash, advisor, diagnosis)
      email_params = {
        advisor: advisor,
        visit_date: diagnosis.visit.happened_at_localized,
        company_name: diagnosis.visit.company_name,
        company_contact: diagnosis.visit.visitee,
        questions_with_needs_description: expert_hash[:questions_with_needs_description]
      }
      ExpertMailer.notify_company_needs(expert_hash[:expert], email_params).deliver_now
    end
  end
end
