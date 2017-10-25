# frozen_string_literal: true

class UserNotificationMailerService
  class << self
    def send_yesterday_modification_notifications
      associations = [diagnosed_need: [diagnosis: [visit: [:advisor, facility: [:company]]]]]
      user_selected_assistance_experts_hash = SelectedAssistanceExpert.includes(associations).updated_yesterday
                                                                      .group_by do |selected_assistance_expert|
        selected_assistance_expert.diagnosed_need.diagnosis.visit.advisor
      end

      user_selected_assistance_experts_hash.each do |user, selected_assistance_experts|
        yesterday_modifications = create_yesterday_modification_array selected_assistance_experts

        break unless yesterday_modifications.count.positive?
        UserMailer.delay.yesterday_modifications(user, yesterday_modifications)
      end
    end

    private

    def create_yesterday_modification_array(selected_assistance_experts)
      yesterday_modifications = selected_assistance_experts.map do |selected_assistance_expert|
        convert_to_modification_hash selected_assistance_expert
      end
      yesterday_modifications.reject do |modification|
        modification[:old_status] == modification[:current_status]
      end
    end

    def convert_to_modification_hash(selected_assistance_expert)
      modification = {}
      fill_standard_information modification, selected_assistance_expert
      fill_status_information modification, selected_assistance_expert
    end

    def fill_standard_information(modification_hash, selected_assistance_expert)
      modification_hash[:expert_name] = selected_assistance_expert.expert_full_name
      modification_hash[:expert_institution] = selected_assistance_expert.expert_institution_name
      modification_hash[:question_title] = selected_assistance_expert.diagnosed_need.question_label
      modification_hash[:company_name] = selected_assistance_expert.diagnosed_need
                                                                   .diagnosis.visit
                                                                   .facility.company.name_short
      modification_hash[:start_date] = selected_assistance_expert.created_at
      modification_hash
    end

    def fill_status_information(modification_hash, selected_assistance_expert)
      modification_hash[:old_status] = selected_assistance_expert.revision_at(Date.yesterday)&.status || 'quo'
      modification_hash[:current_status] = selected_assistance_expert.status
      modification_hash
    end
  end
end
