module Reminders
  class NeedsController < BaseController
    before_action :find_territories
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
      @status = t("reminders.needs.header.#{action}").downcase
      needs = @territory.present? ? @territory.needs : Need.all

      @needs = needs
        .reminders_to(action)
        .includes(:subject).page(params[:page])

      @action = action
      render :index
    end
  end
end
