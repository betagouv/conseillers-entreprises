module Reminders
  class NeedsController < RemindersController
    before_action :find_territories
    before_action :count_needs

    def index
      retrieve_needs :reminder_quo_not_taken
      @action_path = [:poke, :reminders_action]
    end

    def to_recall
      retrieve_needs :reminder_to_recall
      render :index
    end

    def institutions
      retrieve_needs :reminder_institutions
      @action_path = [:warn, :reminders_action]
      render :index
    end

    def abandoned
      retrieve_needs :abandoned_without_taking_care
      @action_path = [:archive, :need]
      render :index
    end

    def rejected
      retrieve_needs :rejected
      @action_path = [:archive, :need]
      render :index
    end

    private

    def retrieve_needs(scope)
      @needs = if @territory.present?
        Need.diagnosis_completed.send(scope).by_territory(@territory).includes(:subject).page(params[:page])
      else
        Need.diagnosis_completed.send(scope).includes(:subject).page(params[:page])
      end
      @status = t("reminders.needs.header.#{scope}").downcase
    end
  end
end
