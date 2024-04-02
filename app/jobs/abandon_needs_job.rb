class AbandonNeedsJob < ApplicationJob
  queue_as :low_priority

  def perform
    Need.status_quo
      .without_action('abandon')
      .without_action('refused')
      .where(created_at: ..Need::REMINDERS_DAYS[:abandon].days.ago).find_each do |need|
      CompanyMailer.failed_need(need).deliver_later(queue: 'low_priority')
      need.reminders_actions.create(category: 'abandon')
    end
  end
end
