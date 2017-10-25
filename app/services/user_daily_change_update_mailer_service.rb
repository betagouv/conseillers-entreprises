# frozen_string_literal: true

class UserDailyChangeUpdateMailerService
  class << self
    def send_daily_change_updates
      associations = [diagnosed_need: [diagnosis: [visit: [:advisor, facility: [:company]]]]]
      user_selected_assistance_experts_hash = SelectedAssistanceExpert.includes(associations).updated_yesterday
                                                                      .group_by do |selected_assistance_expert|
        selected_assistance_expert.diagnosed_need.diagnosis.visit.advisor
      end

      user_selected_assistance_experts_hash.each do |user, selected_assistance_experts|
        change_updates = create_change_update_array selected_assistance_experts

        break if change_updates.empty?
        UserMailer.delay.daily_change_update(user, change_updates)
      end
    end

    private

    def create_change_update_array(selected_assistance_experts)
      change_array = selected_assistance_experts.map do |selected_assistance_expert|
        convert_to_change_hash selected_assistance_expert
      end
      change_array.reject { |change| change[:old_status] == change[:current_status] }
    end

    def convert_to_change_hash(selected_assistance_expert)
      change_hash = {}
      fill_standard_information change_hash, selected_assistance_expert
      fill_status_information change_hash, selected_assistance_expert
    end

    def fill_standard_information(change_hash, selected_assistance_expert)
      change_hash[:expert_name] = selected_assistance_expert.expert_full_name
      change_hash[:expert_institution] = selected_assistance_expert.expert_institution_name
      change_hash[:question_title] = selected_assistance_expert.diagnosed_need.question_label
      change_hash[:company_name] = selected_assistance_expert.diagnosed_need
                                                             .diagnosis.visit
                                                             .facility.company.name_short
      change_hash[:start_date] = selected_assistance_expert.created_at.to_date
      change_hash
    end

    def fill_status_information(change_hash, selected_assistance_expert)
      change_hash[:old_status] = selected_assistance_expert.revision_at(Date.yesterday)&.status || 'quo'
      change_hash[:current_status] = selected_assistance_expert.status
      change_hash
    end
  end
end
