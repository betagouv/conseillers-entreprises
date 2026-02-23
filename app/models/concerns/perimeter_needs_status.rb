module PerimeterNeedsStatus
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #perimeter_received_needs

  def territory_needs_quo
    territory_needs_match_not_archived
      .merge(Match.status_quo)
  end

  def territory_needs_quo_active
    territory_needs_match_not_archived
      .merge(Match.with_status_quo_active)
  end

  def territory_needs_taking_care
    territory_needs_match_not_archived
      .merge(Match.status_taking_care)
  end

  def territory_needs_done
    territory_needs_match_not_archived
      .merge(Match.with_status_done)
  end

  def territory_needs_not_for_me
    territory_needs_match_not_archived
      .merge(Match.status_not_for_me)
  end

  def territory_needs_expired
    territory_needs_match_not_archived
      .merge(Match.with_status_expired)
  end

  ## Helpers
  #
  def territory_needs_match_not_archived
    perimeter_received_needs
      .distinct
      .merge(Match.not_archived)
  end

  def direct_territory_needs_quo_active
    direct_territory_needs_match_not_archived.merge(Match.with_status_quo_active)
  end

  def direct_territory_needs_taking_care
    direct_territory_needs_match_not_archived.merge(Match.status_taking_care)
  end

  def direct_territory_needs_done
    direct_territory_needs_match_not_archived.merge(Match.with_status_done)
  end

  def direct_territory_needs_not_for_me
    direct_territory_needs_match_not_archived.merge(Match.status_not_for_me)
  end

  def direct_territory_needs_expired
    direct_territory_needs_match_not_archived.merge(Match.with_status_expired)
  end

  def direct_territory_needs_match_not_archived
    received_needs_including_from_deleted_experts.distinct.merge(Match.not_archived)
  end
end
