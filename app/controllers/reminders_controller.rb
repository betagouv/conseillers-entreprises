class RemindersController < ApplicationController
  before_action :authenticate_admin!
  before_action :maybe_review_expert_subjects

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
      expert.needs_quo.abandoned.count
    end.reverse
  end

  def show
    retrieve_needs(:needs_quo)
  end

  def needs_taking_care
    retrieve_needs(:needs_taking_care)
    render :show
  end

  def needs_taking_care_by_others
    retrieve_needs(:needs_others_taking_care)
    render :show
  end

  def reminders_notes
    @expert = retrieve_expert
    @expert.update(safe_params[:expert])
  end

  private

  def retrieve_territory
    safe_params = params.permit(:territory)
    if safe_params[:territory].present?
      Territory.find(safe_params[:territory])
    end
  end

  def safe_params
    params.permit(:id, expert: :reminders_notes)
  end

  def retrieve_expert
    Expert.find(safe_params[:id])
  end

  def retrieve_needs(status)
    @expert = retrieve_expert
    @needs = @expert.send(status).page params[:page]
  end
end
