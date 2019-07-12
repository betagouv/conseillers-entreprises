class RemindersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @territories = Territory.all.order(:bassin_emploi, :name)
    @territory = retrieve_territory
    experts_pool = @territory&.all_experts || Expert.all
    @active_experts = experts_pool.with_active_abandoned_matches.sort_by do |expert|
      # This page makes _many_ DB requests, some of them multiple times.
      # Unfortunately, preloading associations wouldn’t help here; we could
      # * cache the abandoned counts in new expert columns
      # * russian-doll cache each expert partial.
      # As this is currently only used by admins, and loads in a second or two,
      # let’s optimize it later.
      expert.needs_quo.abandoned.count + expert.needs_taking_care.abandoned.count
    end.reverse
  end

  def show
    @expert = retrieve_expert
    @needs_quo = @expert.needs_quo
    @needs_taking_care = @expert.needs_taking_care
    @needs_others_taking_care = @expert.needs_others_taking_care
  end

  private

  def retrieve_territory
    safe_params = params.permit(:territory)
    if safe_params[:territory].present?
      Territory.find(safe_params[:territory])
    end
  end

  def retrieve_expert
    safe_params = params.permit(:id)
    expert = Expert.find(safe_params[:id])
    expert
  end
end
