class NeedsService
  def self.archive_old_needs
    Need.archived(false).for_reminders.where(created_at: ..Need::ARCHIVE_DELAY.ago).each do |need|
      need.update(archived_at: Time.now)
    end
  end

  def self.abandon_needs
    Need.archived(false).for_reminders.not_abandoned.where(created_at: ..Need::REMINDERS_DAYS[:will_be_abandoned].days.ago).each do |need|
      # si le besoin a aucun email envoyé et qu'il a plus de 45
      # ou si le besoin a un email envoyé depuis plus de 10 jours et que le besoin a plus de 21 jours
      if (need.last_chance_email_sent_at.blank? && need.created_at <= Need::REMINDERS_DAYS[:archive].days.ago) ||
        (need.last_chance_email_sent_at.present? && (need.last_chance_email_sent_at <= 10.days.ago && need.created_at <= Need::REMINDERS_DAYS[:will_be_abandoned].days.ago))
        need.update(abandoned_at: Time.now, abandoned_email_sent: true)
        CompanyMailer.abandoned_need(need).deliver_later
      end
    end
  end
end
