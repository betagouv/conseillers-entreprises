module Reminders
  class NeedsController < ApplicationController
    before_action :authenticate_admin!
    before_action :maybe_review_expert_subjects

    layout 'side_menu'

    def index
      @needs = Need.reminder_quo_not_taken.page params[:page]
      @status = t('reminders.needs.menu.treat').downcase
    end

    def in_progress
      @needs = Need.reminder_quo_not_taken_in_progress.page params[:page]
      @status = t('reminders.needs.menu.in_progress').downcase
      render :index
    end

    def abandoned
      @needs = Need.abandoned_without_taking_care.page params[:page]
      @status = t('reminders.needs.menu.abandoned').downcase
      render :index
    end
  end
end
