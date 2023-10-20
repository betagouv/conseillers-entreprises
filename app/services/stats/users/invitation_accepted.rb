module Stats::Users
  class InvitationAccepted
    include ::Stats::MiniStats

    def main_query
      User.not_deleted.invitation_accepted.distinct
    end
  end
end
