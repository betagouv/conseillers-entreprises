module Reminders
  class ExpertsController < BaseController
    include Inbox
    helper_method :inbox_collections_counts
    before_action :setup_territory_filters, only: %i[index]
    before_action :find_current_territory, only: %i[index]
    before_action :collections_counts, only: %i[index]
    before_action :retrieve_expert, except: :index

    def index
      @active_experts = to_remind_experts
        .includes(:antenne)
        .most_needs_quo_first
        .page params[:page]
    end

    def show
      redirect_to action: :quo
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
  end
end
