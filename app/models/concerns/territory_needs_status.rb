module TerritoryNeedsStatus
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #perimeter_received_needs

  def territory_needs_quo
    perimeter_received_needs
      .merge(Match.status_quo)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_quo_active
    perimeter_received_needs
      .merge(Match.with_status_quo_active)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_taking_care
    perimeter_received_needs
      .merge(Match.status_taking_care)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_done
    perimeter_received_needs
      .merge(Match.with_status_done)
      .where(matches: { archived_at: nil })
      .distinct
  end

  def territory_needs_not_for_me
    perimeter_received_needs
      .merge(Match.status_not_for_me)
      .where(matches: { archived_at: nil })
      .distinct
  end

  # Il faut les conditions statut + not_archived dans la même conditions
  # Sinon on a des besoins avec 2 MERS (une quo_archived et une refusé par exemple) dans les expirés
  def territory_needs_expired
    perimeter_received_needs
      .merge(Match.with_status_expired)
      .merge(Match.not_archived)
      .distinct
  end
end
