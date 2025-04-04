module TerritoryNeedsStatus
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #perimeter_received_needs

  def territory_needs_quo
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).status_quo)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_quo_active
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).with_status_quo_active)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_taking_care
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).status_taking_care)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_done
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).with_status_done)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_not_for_me
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).status_not_for_me)
      .where(matches: { archived_at: nil })
      .distinct
  end

  # Il faut les conditions statut + not_archived dans la même conditions
  # Sinon on a des besoins avec 2 MERS (une quo_archived et une refusé par exemple) dans les expirés
  def territory_needs_expired
    perimeter_received_needs
      .where(matches: perimeter_received_matches_from_needs(perimeter_received_needs).with_status_expired.not_archived)
      .distinct
  end
end
