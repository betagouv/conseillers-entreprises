# frozen_string_literal: true

class ExpertReminderService
  class << self
    def send_reminders
      Expert.with_active_matches.each do |expert|
        ExpertMailer.remind_involvement(expert).deliver_later
      end
    end
  end
end
