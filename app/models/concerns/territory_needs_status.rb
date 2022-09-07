module TerritoryNeedsStatus
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #perimeter_received_needs

  def territory_needs_quo
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).status_quo)
      .where(matches: { archived_at: nil })
      .archived(false)
  end

  def territory_needs_taking_care
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).status_taking_care)
      .where(matches: { archived_at: nil })
      .archived(false)
  end

  def territory_needs_done
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).with_status_done)
      .where(matches: { archived_at: nil })
      .archived(false)
  end

  def territory_needs_not_for_me
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).status_not_for_me)
      .where(matches: { archived_at: nil })
      .archived(false)
  end

  def territory_needs_archived
    perimeter_received_needs
      .archived(true)
      .or(perimeter_received_needs.where.not(matches: { archived_at: nil }))
  end

  def territory_needs_expired
    perimeter_received_needs.abandoned.distinct
  end
end
