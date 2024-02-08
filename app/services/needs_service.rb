class NeedsService
  def self.archive_expired_matches
    # Archive les vieilles MER (et donc les besoins dans BAL de certains conseillers) non pris en charge pour ne pas saturer l’onglet "expirés" des conseillers
    Match.archived(false)
      .with_status_expired
      .where(sent_at: ..Need::ARCHIVE_DELAY.ago)
      .update_all(archived_at: Time.zone.now)
  end
end
