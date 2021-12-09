module Reminders
  class ExpertsController < BaseController
    include Inbox
    helper_method :inbox_collections_counts
    before_action :setup_territory_filters, :find_current_territory, :collections_counts, only: %i[index critical_rate worrying_rate pending_rate]
    before_action :retrieve_expert, except: %i[index critical_rate worrying_rate pending_rate]

    def index
      redirect_to action: :critical_rate
    end

    def critical_rate
      render_collection(:critical_rate)
    end

    def worrying_rate
      render_collection(:worrying_rate)
    end

    def pending_rate
      render_collection(:pending_rate)
    end

    def quo
      retrieve_needs(@expert, :quo, :quo)
    end

    def taking_care
      retrieve_needs(@expert, :taking_care, :quo)
    end

    def done
      retrieve_needs(@expert, :done, :quo)
    end

    def not_for_me
      retrieve_needs(@expert, :not_for_me, :quo)
    end

    def expired
      retrieve_needs(@expert, :expired, :quo)
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

    def render_collection(action)
      @active_experts = PositionningRate::Collection.new(territory_experts).send(action)
        .includes(:antenne)
        .most_needs_quo_first
        .page params[:page]

      @action = action
      render :index
    end
  end
end
