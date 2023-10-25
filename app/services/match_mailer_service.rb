# frozen_string_literal: true

class MatchMailerService
  def self.deduplicated_notify_status(match, previous_status)
    scheduled = Sidekiq::ScheduledSet.new

    scheduled.each do |job|
      return if job.queue != 'match_notify'
      if job.klass == SendStatusNotificationJob.to_s && job.args.first == match.id
        job.delete
      end
    end

    SendStatusNotificationJob.perform_in(1.minute, match.id, previous_status)
  end
end
