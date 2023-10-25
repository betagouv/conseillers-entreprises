class AbandonNeedsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    Need.archived(false)
      .status_quo
      .without_action('abandon')
      .where(created_at: ..Need::REMINDERS_DAYS[:last_chance].days.ago).each do |need|
      # Envoie de l'email d'abandon a l’entreprise si :
      # le besoin a aucun email envoyé et qu'il a plus de 45 jours
      # ou si le besoin a un email envoyé depuis plus de 10 jours et que le besoin a plus de 21 jours
      if (!need.has_action?('last_chance') && need.created_at <= Need::REMINDERS_DAYS[:abandon].days.ago) ||
        (need.has_action?('last_chance') && need.reminders_actions.find_by(category: 'last_chance').created_at <= 10.days.ago)
        CompanyMailer.abandoned_need(need).deliver_later(queue: 'low_priority')
        need.reminders_actions.create(category: 'abandon')
      end
    end
  end
end
