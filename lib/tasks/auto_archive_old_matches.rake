task auto_archive_old_matches: :environment do
  Match.joins(:need)
    .archived(false)
    .where(status: :quo, created_at: ..60.days.ago, needs: { status: [:taking_care, :done, :done_no_help, :done_not_reachable] })
    .map { |m| m.update_attribute(:archived_at, Time.zone.now) }
end
