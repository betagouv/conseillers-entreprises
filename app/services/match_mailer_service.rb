# frozen_string_literal: true

class MatchMailerService
  def initialize(match)
    @match = match
  end

  def deduplicated_notify_status(previous_status)
    scheduled = Sidekiq::ScheduledSet.new

    # Fetch the oldest status from the previous jobs
    old_status = scheduled.first&.args&.last
    old_status ||= previous_status

    scheduled.each do |job|
      return if job.queue != 'match_notification'
      if job.klass == CompanyEmails::SendStatusNotificationJob.to_s && job.args.first == @match.id
        job.delete
      end
    end

    # Reschedule a new email, if needed.
    if @match.status != old_status
      CompanyEmails::SendStatusNotificationJob.perform_in(1.minute, @match.id, old_status)
    end
  end
end
