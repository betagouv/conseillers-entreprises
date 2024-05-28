class SendExpertsRemindersJob < ApplicationJob
  queue_as :low_priority

  def perform
    Expert.not_deleted.with_active_matches.each do |expert|
      ExpertMailer.with(expert: expert).remind_involvement.deliver_later
    end
  end
end
