# frozen_string_literal: true

class ExpertReminderService
  class << self
    def reminders
      reminders_taken_not_done
        .deep_merge(reminders_quo_not_taken)
    end

    def send_reminders
      reminders.each do |expert, matches|
        ExpertMailer.delay.remind_involvement(expert,
                                              matches[:taken_not_done],
                                              matches[:quo_not_taken])
      end
    end

    private

    def reminders_taken_not_done
      matches = Need.taken_not_done_after_3_weeks.flat_map(&:matches)
      matches_reminders(matches, :taken_not_done)
    end

    def reminders_quo_not_taken
      matches = Need.quo_not_taken_after_3_weeks.flat_map(&:matches)
      matches_reminders(matches, :quo_not_taken)
    end

    def matches_reminders(matches, key)
      matches.delete_if{ |m| m.status_not_for_me? }
      matches.delete_if{ |m| m.expert.nil? }

      matches_reminders = {}
      matches.each do |m|
        matches_reminders[m.expert] ||= {}
        matches_reminders[m.expert][key] ||= []
        matches_reminders[m.expert][key] << m
      end

      matches_reminders
    end
  end
end
