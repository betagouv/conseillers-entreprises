module InvolvementConcern
  extend ActiveSupport::Concern

  def needs_taking_care
    received_needs
      .where(matches: received_matches.status_taking_care)
      .archived(false)
  end

  def needs_quo
    received_needs
      .by_status(:quo)
      .where.not(matches: received_matches.status_not_for_me)
      .archived(false)
  end

  def needs_others_taking_care
    received_needs
      .by_status(:taking_care)
      .where.not(matches: received_matches.status_taking_care)
      .archived(false)
  end

  def needs_rejected
    received_needs
      .where(matches: received_matches.status_not_for_me)
      .archived(false)
  end

  def needs_done
    received_needs
      .by_status(:done)
      .archived(false)
  end

  def needs_archived
    received_needs
      .archived(true)
  end
end
