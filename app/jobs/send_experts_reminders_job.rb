class SendExpertsRemindersJob < ApplicationJob
  queue_as :low_priority

  def perform
    Expert.not_deleted.with_active_matches.each do |expert|
      ExpertMailer.remind_involvement(expert).deliver_later(queue: 'low_priority')
    end
  end
end
