# frozen_string_literal: true

class ExpertReminderService
  class << self
    def send_reminders
      @experts_matches = {}
      build_matches_taken_not_done
      build_matches_quo_not_taken
      @experts_matches.each do |expert, expert_matches|
        ExpertMailer.delay.remind_involvement(expert,
          expert_matches.taken_not_done.compact,
          expert_matches.quo_not_taken.compact)
      end
    end

    private

    ExpertMatches = Struct.new(:taken_not_done, :quo_not_taken)

    def add_expert_match(expert, args)
      expert_matches = @experts_matches[expert] ||= ExpertMatches.new([], [])
      expert_matches.taken_not_done << args[:taken_not_done]
      expert_matches.quo_not_taken << args[:quo_not_taken]
    end

    def build_matches_taken_not_done
      Need.taken_not_done_after_3_weeks.each do |need|
        need.matches.each do |match|
          if match.status_not_for_me? # don’t send reminders for already rejected matches
            next
          end

          expert = match.expert
          if !match.expert
            next
          end

          add_expert_match(expert, taken_not_done: match)
        end
      end
    end

    def build_matches_quo_not_taken
      Need.quo_not_taken_after_3_weeks.each do |need|
        need.matches.each do |match|
          if match.status_not_for_me? # don’t send reminders for already rejected matches
            next
          end

          expert = match.expert
          if !match.expert
            next
          end

          add_expert_match(expert, quo_not_taken: match)
        end
      end
    end
  end
end
