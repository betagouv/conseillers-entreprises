module Reminders
  class NeedsController < BaseController
    before_action :find_territories
    before_action :count_needs

    def index
      redirect_to action: :to_poke
    end

    def to_poke
      retrieve_needs :reminders_to_poke
      @action_path = [:poke, :reminders_action]
      render :index
    end

    def to_recall
      retrieve_needs :reminders_to_recall
      @action_path = [:recall, :reminders_action]
      render :index
    end

    def to_warn
      retrieve_needs :reminders_to_warn
      @action_path = [:warn, :reminders_action]
      render :index
    end

    def to_archive
      retrieve_needs :reminders_to_archive
      @action_path = [:archive, :need]
      render :index
    end

    private

    def retrieve_needs(scope)
      @needs = Need.diagnosis_completed.send(scope)
      if @territory.present?
        @needs = @needs.by_territory(@territory)
      end
      @needs = @needs.includes(:subject).page(params[:page])
      @status = t("reminders.needs.header.#{scope}").downcase
    end
  end
end
