class AbandonNeedsJob < ApplicationJob
  queue_as :low_priority

  def perform
    Need.status_quo
      .without_action('abandon')
      .where(created_at: ..Need::REMINDERS_DAYS[:last_chance].days.ago).find_each do |need|
      # Envoie de l'email d'abandon a l’entreprise si le besoin a plus de 45 jours
      if !need.has_action?('last_chance') && need.created_at <= Need::REMINDERS_DAYS[:abandon].days.ago
        CompanyMailer.abandoned_need(need).deliver_later(queue: 'low_priority')
        need.reminders_actions.create(category: 'abandon')
      end
    end
  end
end
