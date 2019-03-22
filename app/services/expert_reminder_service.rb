# frozen_string_literal: true

class ExpertReminderService
  class << self
    def send_reminders
      @persons_matches = {}
      build_matches_taken_not_done
      build_matches_quo_not_taken
      @persons_matches.each do |person, person_matches|
        ExpertMailer.delay.remind_involvement(person,
          person_matches.taken_not_done.compact,
          person_matches.quo_not_taken.compact)
      end
    end

    private

    PersonMatches = Struct.new(:taken_not_done, :quo_not_taken)

    def add_person_match(person, args)
      person_matches = @persons_matches[person] ||= PersonMatches.new([], [])
      person_matches.taken_not_done << args[:taken_not_done]
      person_matches.quo_not_taken << args[:quo_not_taken]
    end

    def build_matches_taken_not_done
      DiagnosedNeed.taken_not_done_after_3_weeks.each do |diagnosed_need|
        diagnosed_need.matches.each do |match|
          if match.status_not_for_me? # don’t send reminders for already rejected matches
            next
          end

          person = match.person
          if !match.person
            next
          end

          add_person_match(person, taken_not_done: match)
        end
      end
    end

    def build_matches_quo_not_taken
      DiagnosedNeed.quo_not_taken_after_3_weeks.each do |diagnosed_need|
        diagnosed_need.matches.each do |match|
          if match.status_not_for_me? # don’t send reminders for already rejected matches
            next
          end

          person = match.person
          if !match.person
            next
          end

          add_person_match(person, quo_not_taken: match)
        end
      end
    end
  end
end
