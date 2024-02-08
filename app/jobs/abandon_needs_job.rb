class AbandonNeedsJob < ApplicationJob
  queue_as :low_priority

  def perform
    Need.status_quo
      .without_action('abandon')
      .where(created_at: ..Need::REMINDERS_DAYS[:abandon].days.ago).find_each do |need|
      # Envoie de l'email d'abandon a l’entreprise si le besoin a aucun email envoyé et qu'il a plus de 45 jours
      if need.abandoned_email_sent == false
        CompanyMailer.abandoned_need(need).deliver_later(queue: 'low_priority')
        need.update(abandoned_email_sent: true)
      end
      need.reminders_actions.create(category: 'abandon')
    end
  end
end
