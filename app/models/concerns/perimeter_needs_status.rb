module PerimeterNeedsStatus
  extend ActiveSupport::Concern

  # These methods can be called on any object that implements #perimeter_received_needs

  def territory_needs_quo(aggregate:)
    base_needs(aggregate:)
      .merge(Match.status_quo)
  end

  def territory_needs_quo_active(aggregate:)
    base_needs(aggregate:)
      .merge(Match.with_status_quo_active)
  end

  def territory_needs_taking_care(aggregate:)
    base_needs(aggregate:)
      .merge(Match.status_taking_care)
  end

  def territory_needs_done(aggregate:)
    base_needs(aggregate:)
      .merge(Match.with_status_done)
  end

  def territory_needs_not_for_me(aggregate:)
    base_needs(aggregate:)
      .merge(Match.status_not_for_me)
  end

  def territory_needs_expired(aggregate:)
    base_needs(aggregate:)
      .merge(Match.with_status_expired)
  end

  def territory_needs(collection_name, aggregate:)
    public_send(:"territory_needs_#{collection_name}", aggregate:)
  end

  ## Helpers
  #
  def base_needs(aggregate:)
    (aggregate ? perimeter_received_needs : received_needs_including_from_deleted_experts)
      .distinct
      .merge(Match.not_archived)
  end
end
