module Reminders
  class NeedsController < ApplicationController
    before_action :authenticate_admin!
    before_action :maybe_review_expert_subjects

    layout 'side_menu'

    def index
      @needs = Need.reminder_quo_not_taken.page params[:page]
      @status = t('reminders.needs.menu.treat').downcase
    end
  end
end
