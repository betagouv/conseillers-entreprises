module Reminders
  class NeedsController < BaseController
    before_action :find_territories
    before_action :count_needs

    def index
      redirect_to action: :to_poke
    end

    def to_poke
      render_collection(:poke)
    end

    def to_recall
      render_collection(:recall)
    end

    def to_warn
      render_collection(:warn)
    end

    def to_archive
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
