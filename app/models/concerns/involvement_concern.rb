module InvolvementConcern
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #received_needs
  # i.e. User, Experts, Antennes and Institutions.

  def needs_quo
    received_needs.distinct
      .merge(Match.not_archived)
      .merge(Match.status_quo)
  end

  def needs_quo_active
    received_needs.distinct
      .merge(Match.not_archived)
      .merge(Match.with_status_quo_active)
  end

  def needs_taking_care
    received_needs.distinct
      .merge(Match.not_archived)
      .merge(Match.status_taking_care)
  end

  def needs_done
    received_needs.distinct
      .merge(Match.not_archived)
      .merge(Match.with_status_done)
  end

  def needs_not_for_me
    received_needs.distinct
      .merge(Match.not_archived)
      .merge(Match.status_not_for_me)
  end

  def needs_expired
    received_needs.distinct
      .merge(Match.not_archived)
      .merge(Match.with_status_expired)
  end

  def needs_others_taking_care
    needs_quo
      .status_taking_care
  end
end
