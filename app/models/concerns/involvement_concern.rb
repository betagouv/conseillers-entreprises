module InvolvementConcern
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #received_needs
  # i.e. User, Experts, Antennes and Institutions.

  def needs_quo
    received_needs
      .where(matches: received_matches.status_quo)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end

  def needs_quo_active
    received_needs
      .where(matches: received_matches.with_status_quo_active)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end

  def needs_taking_care
    received_needs
      .where(matches: received_matches.status_taking_care)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end

  def needs_done
    received_needs
      .where(matches: received_matches.with_status_done)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end

  def needs_not_for_me
    received_needs
      .where(matches: received_matches.status_not_for_me)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end

  def needs_archived
    received_needs
      .archived(true)
      .or(received_needs.where.not(matches: { archived_at: nil }))
      .distinct
  end

  def needs_expired
    received_needs
      .where(matches: received_matches.with_status_expired)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end

  def needs_others_taking_care
    received_needs
      .status_taking_care
      .where(matches: received_matches.status_quo)
      .where(matches: { archived_at: nil })
      .archived(false)
      .distinct
  end
end
