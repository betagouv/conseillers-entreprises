# frozen_string_literal: true

class UnusedUsersService
  class << self
    def delete_users
      # Don't write 'invitation_sent_at:  ..7.months.ago' because there is an error on ruby_parser used by Brakeman
      users = User.where(invitation_accepted_at: nil, invitation_sent_at: 10.years.ago..7.months.ago, encrypted_password: '')
      users.each do |user|
        expert = user.personal_skillsets.first
        next if expert.present? && (expert.received_matches.any? || user.experts.many?)

        user.experts.each { |e| e.users.delete(user) }
        Expert.joins(:users).where("users.id" => user.id).each { |e| e.users.delete(user) }

        if expert.present? && expert.users.count < 2
          expert.transaction do
            # There is dependent: :destroy but destroy call soft_delete
            expert.experts_subjects.delete_all
            expert.communes = []
            expert.delete
          end
        end
        begin
          user.delete
        rescue
          user.soft_delete
        end
      end
    end
  end
end
