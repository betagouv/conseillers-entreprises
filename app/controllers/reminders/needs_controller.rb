module Reminders
  class NeedsController < BaseController
    before_action :find_territories
    before_action :count_needs

    def index
      redirect_to action: :to_poke
    end

    def to_poke
      @action_path = [:poke, :reminders_action]
      render_collection(:poke)
    end

    def to_recall
      @action_path = [:recall, :reminders_action]
      render_collection(:recall)
    end

    def to_warn
      @action_path = [:warn, :reminders_action]
      render_collection(:warn)
    end

    def to_archive
      @action_path = [:archive, :need]
      render_collection(:archive)
    end

    private

    def render_collection(action)
      @status = t("reminders.needs.header.#{action}").downcase
      needs = @territory.present? ? @territory.needs : Need.all

      @needs = needs
        .reminders_to(action)
        .includes(:subject).page(params[:page])
      render :index
    end
  end
end
