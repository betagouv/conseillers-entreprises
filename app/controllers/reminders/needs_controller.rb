module Reminders
  class NeedsController < BaseController
    before_action :setup_territory_filters
    before_action :find_current_territory
    before_action :collections_counts

    def index
      redirect_to action: :poke
    end

    def poke
      render_collection(:poke)
    end

    def recall
      render_collection(:recall)
    end

    def warn
      render_collection(:warn)
    end

    def archive
      render_collection(:archive)
    end

    private

    def render_collection(action)
      @needs = territory_needs
        .reminders_to(action)
        .includes(:subject, :feedbacks, matches: { expert: :antenne}).page(params[:page])

      @action = action
      render :index
    end
  end
end
