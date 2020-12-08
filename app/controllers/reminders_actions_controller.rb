# frozen_string_literal: true

class RemindersActionsController < ApplicationController
  before_action :retrieve_need

  def poke
    @need.reminders_actions.create(category: :poke)
    redirect_to to_poke_reminders_needs_path, notice: t('reminders_actions.processed_need', company: @need.company.name)
  end

  def recall
    @need.reminders_actions.create(category: :recall)
    redirect_to to_recall_reminders_needs_path, notice: t('reminders_actions.processed_need', company: @need.company.name)
  end

  def warn
    @need.reminders_actions.create(category: :warn)
    redirect_to institutions_reminders_needs_path, notice: t('reminders_actions.processed_need', company: @need.company.name)
  end

  private

  def retrieve_need
    @need = Need.find(params.permit(:id)[:id])
  end
end
