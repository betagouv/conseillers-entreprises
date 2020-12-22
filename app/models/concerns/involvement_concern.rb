module InvolvementConcern
  extend ActiveSupport::Concern

  def needs_quo
    query = received_needs
      .where(matches: received_matches.status_quo)
      .archived(false)

    # Taken by no one, or taken by someone else but not old yet
    query.status_quo
         .or(query.where.not(id: Need.in_reminders_range(:archive)))
  end

  def needs_others_taking_care
    query = received_needs
      .where(matches: received_matches.status_quo)
      .archived(false)

    query.not_status_quo.in_reminders_range(:archive)
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
end
