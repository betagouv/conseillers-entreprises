# frozen_string_literal: true

class ExpertMailersService
  # TODO: Refactor :)

  class << self
    def send_assistances_email(advisor:, diagnosis:, assistance_expert_ids:)
      assistances_experts = retrieve_assistances_experts(assistance_expert_ids)
      questions_grouped_by_experts = questions_grouped_by_experts(assistances_experts, diagnosis)
      questions_grouped_by_experts.each { |expert_hash| notify_expert(expert_hash, advisor, diagnosis) }
    end

    def send_relay_assistances_email(relay:, diagnosed_need_ids:, advisor:, diagnosis:)
      diagnosed_needs = DiagnosedNeed.of_diagnosis(diagnosis).where(id: diagnosed_need_ids)
      questions_for_relay = questions_for_relay(relay, diagnosed_needs)
      notify_expert(questions_for_relay, advisor, diagnosis)
    end

    private

    def retrieve_assistances_experts(assistance_expert_ids)
      associations = [:expert, :assistance, expert: :institution, assistance: :question]
      AssistanceExpert.where(id: assistance_expert_ids).joins(associations).includes(associations)
    end

    def questions_grouped_by_experts(assistances_experts, diagnosis)
      questions_grouped_by_experts = {}
      assistances_experts.each { |ae| questions_grouped_by_experts_for_ae(ae, diagnosis, questions_grouped_by_experts) }
      questions_grouped_by_experts.values
    end

    def questions_for_relay(relay, diagnosed_needs)
      questions_for_relay = { expert: relay.user }
      questions_for_relay[:questions_with_needs_description] = diagnosed_needs.collect do |diagnosed_need|
        {
          question: diagnosed_need.question,
          need_description: diagnosed_need.content
        }
      end
      questions_for_relay
    end

    def questions_grouped_by_experts_for_ae(assistance_expert, diagnosis, questions_grouped_by_experts)
      expert_id = assistance_expert.expert_id
      diagnosed_need_contents_hash = diagnosed_need_contents_hash(diagnosis)
      if !questions_grouped_by_experts[expert_id]
        questions_grouped_by_experts[expert_id] = init_questions_grouped_by_experts_for_ae(assistance_expert)
      end
      questions_grouped_by_experts[expert_id][:questions_with_needs_description] <<
        questions_with_needs_description_hash(assistance_expert, diagnosed_need_contents_hash)
    end

    def diagnosed_need_contents_hash(diagnosis)
      diagnosed_need_contents_hash = {}
      needs = DiagnosedNeed.of_diagnosis(diagnosis).group(:question_id, :content).select(:question_id, :content)
      needs.each { |need| diagnosed_need_contents_hash[need.question_id] = need.content }
      diagnosed_need_contents_hash
    end

    def init_questions_grouped_by_experts_for_ae(assistance_expert)
      {
        expert: assistance_expert.expert,
        questions_with_needs_description: []
      }
    end

    def questions_with_needs_description_hash(assistance_expert, diagnosed_need_contents_hash)
      question = assistance_expert.assistance.question
      {
        question: question,
        need_description: diagnosed_need_contents_hash[question.id]
      }
    end

    def notify_expert(expert_hash, advisor, diagnosis)
      email_params = {
        advisor: advisor,
        diagnosis_id: diagnosis.id,
        visit_date: diagnosis.visit.happened_on_localized,
        company_name: diagnosis.visit.company_name,
        company_contact: diagnosis.visit.visitee,
        questions_with_needs_description: expert_hash[:questions_with_needs_description]
      }
      ExpertMailer.notify_company_needs(expert_hash[:expert], email_params).deliver_now
    end
  end
end
