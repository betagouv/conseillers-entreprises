# frozen_string_literal: true

class ExpertReminderService
  class << self
    def send_reminders
      Expert.with_active_matches.each do |expert|
        ExpertMailer.delay.remind_involvement(expert)
      end
    end
  end
end
