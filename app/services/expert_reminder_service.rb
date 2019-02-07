# frozen_string_literal: true

class ExpertReminderService
  class << self
    def send_reminders
      @persons_matches = {}
      build_matches_needing_taking_care_update
      build_matches_with_no_one_in_charge
      @persons_matches.each do |person, person_matches|
        ExpertMailer.delay.remind_involvement(person,
          person_matches.needing_taking_care_update.compact,
          person_matches.with_no_one_in_charge.compact)
      end
    end

    private

    PersonMatches = Struct.new(:needing_taking_care_update, :with_no_one_in_charge)

    def add_person_match(person, args)
      person_matches = @persons_matches[person] ||= PersonMatches.new([], [])
      person_matches.needing_taking_care_update << args[:needing_taking_care_update]
      person_matches.with_no_one_in_charge << args[:with_no_one_in_charge]
    end

    def build_matches_needing_taking_care_update
      Match.needing_taking_care_update.each do |match|
        person = match.person
        if !match.person
          next
        end

        add_person_match(person, needing_taking_care_update: match)
      end
    end

    def build_matches_with_no_one_in_charge
      DiagnosedNeed.needing_reminder.each do |diagnosed_need|
        diagnosed_need.matches.each do |match|
          if match.status_not_for_me? # don’t send reminders for already rejected matches
            next
          end

          person = match.person
          if !match.person
            next
          end

          add_person_match(person, with_no_one_in_charge: match)
        end
      end
    end
  end
end
