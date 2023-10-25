class ArchiveExpiredMatchesJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    Match.archived(false)
      .with_status_expired
      .where(created_at: ..Need::ARCHIVE_DELAY.ago)
      .update_all(archived_at: Time.zone.now)
  end
end
