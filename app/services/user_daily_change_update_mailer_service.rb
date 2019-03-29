# frozen_string_literal: true

class UserDailyChangeUpdateMailerService
  class << self
    def send_daily_change_updates
      associations = [need: [diagnosis: [:advisor, facility: [:company]]]]
      user_matches_hash = Match.includes(associations)
        .updated_yesterday
        .group_by do |match|
        match.need.diagnosis.advisor
      end

      user_matches_hash.each do |user, matches|
        change_updates = create_change_update_array matches

        if change_updates.empty?
          break
        end

        UserMailer.delay.daily_change_update(user, change_updates)
      end
    end

    private

    def create_change_update_array(matches)
      change_array = matches.map do |match|
        convert_to_change_hash match
      end
      change_array.reject { |change| change[:old_status] == change[:current_status] }
    end

    def convert_to_change_hash(match)
      change_hash = {}
      fill_standard_information change_hash, match
      fill_status_information change_hash, match
    end

    def fill_standard_information(change_hash, match)
      change_hash[:expert_name] = match.expert_full_name
      change_hash[:expert_institution] = match.expert_institution_name
      change_hash[:subject_title] = match.need.subject
      change_hash[:company_name] = match.need
        .diagnosis.company.name
      change_hash[:start_date] = match.created_at.to_date
      change_hash
    end

    def fill_status_information(change_hash, match)
      change_hash[:old_status] = match.revision_at(1.day.ago)&.status || 'quo'
      change_hash[:current_status] = match.status
      change_hash
    end
  end
end
