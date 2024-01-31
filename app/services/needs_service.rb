class NeedsService
  def self.archive_expired_matches
    # Archive les vieilles MER (et donc les besoins dans BAL de certains conseillers) non pris en charge pour ne pas saturer l’onglet "expirés" des conseillers
    Match.archived(false)
      .with_status_expired
      .where(sent_at: ..Need::ARCHIVE_DELAY.ago)
      .update_all(archived_at: Time.zone.now)
  end

  def self.abandon_needs
    Need.status_quo
      .without_action('abandon')
      .where(created_at: ..Need::REMINDERS_DAYS[:last_chance].days.ago).find_each do |need|
      # Envoie de l'email d'abandon a l’entreprise si :
      # le besoin a aucun email envoyé et qu'il a plus de 45 jours
      # ou si le besoin a un email envoyé depuis plus de 10 jours et que le besoin a plus de 21 jours
      if !need.has_action?('last_chance') && need.created_at <= Need::REMINDERS_DAYS[:abandon].days.ago
        CompanyMailer.abandoned_need(need).deliver_later
        need.reminders_actions.create(category: 'abandon')
      end
    end
  end
end
