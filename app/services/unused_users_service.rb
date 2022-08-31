# frozen_string_literal: true

class UnusedUsersService
  class << self
    def delete_users
      # Don't write 'invitation_sent_at:  ..7.months.ago' because there is an error on ruby_parser used by Brakeman
      users = User.where(invitation_accepted_at: nil, invitation_sent_at: 10.years.ago..7.months.ago, encrypted_password: '')
      users.each do |user|
        # On ne supprime que les utilisateurs avec un expert solo et sans MER envoyée
        expert = user.personal_skillsets.first
        next if expert.present? && (expert.received_matches.any?)

        # On supprime le user des équipes dans lesquelles il serait
        user.experts.each { |e| e.users.delete(user) }

        # on vérifie que l'expert n'a pas d'autres users
        if expert.present? && expert.users.count < 2
          # on supprime les MER jamais envoyées
          expert.not_received_matches.destroy_all
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
