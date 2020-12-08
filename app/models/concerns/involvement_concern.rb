module InvolvementConcern
  extend ActiveSupport::Concern

  def needs_quo
    received_needs
      .where(matches: received_matches.status_quo)
      .archived(false)
  end

  def needs_taking_care
    received_needs
      .where(matches: received_matches.status_taking_care)
      .archived(false)
  end

  def needs_done
    received_needs
      .where(matches: received_matches.status_done)
      .archived(false)
  end

  def needs_not_for_me
    received_needs
      .where(matches: received_matches.status_not_for_me)
      .archived(false)
  end

  def needs_archived
    received_needs
      .archived(true)
  end

  def needs_others_taking_care
    received_needs
      .status_taking_care
      .where(matches: received_matches.status_quo)
      .archived(false)
      .distinct
  end
end
