module InvolvementConcern
  extend ActiveSupport::Concern

  def needs_taking_care
    received_needs
      .where(matches: received_matches.status_taking_care)
      .active
      .archived(false)
  end

  def needs_quo
    received_needs
      .status_quo
      .where.not(matches: received_matches.status_not_for_me)
      .archived(false)
  end

  def needs_others_taking_care
    received_needs
      .status_taking_care
      .where(matches: received_matches.status_quo)
      .archived(false)
  end

  def needs_rejected
    received_needs
      .where(matches: received_matches.status_not_for_me)
      .archived(false)
  end

  def needs_done
    received_needs
      .status_done
      .archived(false)
  end

  def needs_archived
    received_needs
      .archived(true)
  end
end
