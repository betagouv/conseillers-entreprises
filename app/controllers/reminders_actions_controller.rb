# frozen_string_literal: true

class RemindersActionsController < ApplicationController
  def create
    reminders_action = RemindersAction.new(reminders_action_params)
    if reminders_action.save
      flash.notice = t('reminders_actions.processed_need', company: reminders_action.need.company.name)
      redirect_back(fallback_location: poke_reminders_needs_path)
    else
      flash.alert = reminders_action.errors.full_messages.to_sentence
      redirect_back(fallback_location: poke_reminders_needs_path)
    end
  end

  private

  def reminders_action_params
    params.permit(:need_id, :category)
  end
end
