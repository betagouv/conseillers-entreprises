# frozen_string_literal: true

class ExpertReminderService
  class << self
    def send_reminders
      # TODO: #1367 The list of experts here should be the same as /relances/experts
      # (See also Reminders::ExpertsController#index)
      # and consistent with /relances/besoins.
      Expert.with_active_matches.each do |expert|
        ExpertMailer.remind_involvement(expert).deliver_later
      end
    end
  end
end
