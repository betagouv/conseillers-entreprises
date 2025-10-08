module InvolvementConcern
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #received_needs
  # i.e. User, Experts, Antennes and Institutions.

  def needs_quo
    received_need_with_match
      .merge(Match.status_quo)
  end

  def needs_quo_active
    received_need_with_match
      .merge(Match.with_status_quo_active)
  end

  def needs_taking_care
    received_need_with_match
      .merge(Match.status_taking_care)
  end

  def needs_done
    received_need_with_match
      .merge(Match.with_status_done)
  end

  def needs_not_for_me
    received_need_with_match
      .merge(Match.status_not_for_me)
  end

  def needs_expired
    received_need_with_match
      .merge(Match.with_status_expired)
  end

  def needs_others_taking_care
    needs_quo
      .status_taking_care
  end

  ## Helpers
  #
  def received_need_with_match
    received_needs.distinct
      .merge(Match.not_archived)
      .select("needs.*, matches.sent_at as match_sent_at")
  end

  module MatchSentAtAttribute
    extend ActiveSupport::Concern

    included do
      # Let Rails know about match_sent_at, so that it’s converted to an ActiveSupport::TimeWithZone object.
      attribute :match_sent_at, :datetime
    end
  end
  ::Need.include MatchSentAtAttribute
end
