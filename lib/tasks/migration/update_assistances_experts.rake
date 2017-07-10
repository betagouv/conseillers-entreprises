# frozen_string_literal: true

task update_assistances_experts: :environment do
  Assistance.all.each do |assistance|
    AssistanceExpert.create! assistance_id: assistance.id, expert_id: assistance.expert_id
  end
end
