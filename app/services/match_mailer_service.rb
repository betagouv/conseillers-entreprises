# frozen_string_literal: true

class MatchMailerService
  def initialize(match)
    @match = match
  end

  def deduplicated_notify_status(previous_status)
    scheduled = Sidekiq::ScheduledSet.new

    scheduled.each do |job|
      return if job.queue != 'match_notify'
      if job.klass == SendStatusNotificationJob.to_s && job.args.first == @match.id
        job.delete
      end
    end

    SendStatusNotificationJob.perform_in(1.minute, @match.id, previous_status)
  end
end
