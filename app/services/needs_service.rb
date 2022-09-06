class NeedsService
  def self.archive_old_needs
    Need.archived(false).for_reminders.where(created_at: ..Need::ARCHIVE_DELAY.ago).each do |need|
      need.update(archived_at: Time.now)
    end
  end
end
