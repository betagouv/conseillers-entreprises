# frozen_string_literal: true

class ExpertMailersService
  class << self
    def send_assistances_email(advisor:, diagnosis:, assistance_expert_ids:)
      assistances_experts = retrieve_assistances_experts(assistance_expert_ids)
      assistances_grouped_by_experts = assistances_grouped_by_experts(assistances_experts)
      assistances_grouped_by_experts.each { |expert_hash| notify_expert(expert_hash, advisor, diagnosis) }
    end

    def filter_assistances_experts(assistances_experts_hash)
      assistances_experts_hash.select { |_key, value| value == '1' }.keys.map(&:to_i)
    end

    def retrieve_assistances_experts(assistance_expert_ids)
      associations = [:expert, :assistance, expert: :institution, assistance: :question]
      AssistanceExpert.where(id: assistance_expert_ids).joins(associations).includes(associations)
    end

    def assistances_grouped_by_experts(assistances_experts)
      assistances_grouped_by_experts = {}
      assistances_experts.each do |assistance_expert|
        expert_id = assistance_expert.expert_id
        unless assistances_grouped_by_experts[expert_id]
          assistances_grouped_by_experts[expert_id] = { expert: assistance_expert.expert, assistances: [] }
        end
        assistances_grouped_by_experts[expert_id][:assistances] << assistance_expert.assistance
      end
      assistances_grouped_by_experts.values
    end

    def notify_expert(expert_hash, advisor, diagnosis)
      email_params = {
        advisor: advisor,
        visit_date: diagnosis.visit.happened_at_localized,
        company_name: diagnosis.visit.company_name,
        company_contact: diagnosis.visit.visitee,
        assistances: expert_hash[:assistances],
        expert_institution: expert_hash[:expert].institution.name
      }
      ExpertMailer.notify_company_needs(expert_hash[:expert], email_params).deliver_now
    end
  end
end
