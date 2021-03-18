module Reminders
  class ExpertsController < BaseController
    before_action :retrieve_expert, except: :index
    before_action :count_expert_needs, except: %i[index reminders_notes]
    before_action :setup_territory_filters, only: %i[index]
    before_action :find_current_territory, only: %i[index]
    before_action :collections_counts, only: %i[index]

    def index
      experts_pool = @territory&.all_experts || Expert.all
      # TODO: #1367 the list of experts here should actually be built from
      # the needs in the collections in Reminders::NeedsController (for poke, recall, warn and archive).
      # We don’t want all the experts for these needs: we want just the ones who didn’t respond to the match, yet.
      # (It probably is some ruby code, not an ActiveRecord query.)
      @active_experts = experts_pool.with_active_abandoned_matches.includes(:antenne).sort_by do |expert|
        expert.needs_quo.abandoned.count
      end.reverse
    end

    def show
    end

    def needs
      retrieve_needs :reminders_needs_to_call_back
      @action = :recall
    end

    def needs_taking_care
      retrieve_needs :needs_taking_care
      render :needs
    end

    def needs_taking_care_by_others
      retrieve_needs :needs_others_taking_care
      render :needs
    end

    def reminders_notes
      @expert.update(safe_params[:expert])
    end

    private

    def safe_params
      params.permit(:id, expert: :reminders_notes)
    end

    def retrieve_expert
      @expert = Expert.find(safe_params[:id])
    end

    def retrieve_needs(status)
      @needs = @expert.send(status).diagnosis_completed.page params[:page]
    end

    def count_expert_needs
      @count_expert_needs = Rails.cache.fetch(["reminders_expert_need", @expert.received_needs]) do
        {
          reminders_needs_to_call_back: @expert.reminders_needs_to_call_back.diagnosis_completed.size,
            needs_taking_care: @expert.needs_taking_care.diagnosis_completed.size,
            needs_others_taking_care: @expert.needs_others_taking_care.diagnosis_completed.size
        }
      end
    end
  end
end
