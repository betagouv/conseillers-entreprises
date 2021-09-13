# frozen_string_literal: true

class MatchMailerService
  def self.deduplicated_notify_status(match, previous_status)
    if Rails.env.development? && ENV['DEVELOPMENT_INLINE_JOBS'].to_b
      notify_status(match, previous_status)
      return
    end

    # Kill similar jobs that are not run yet (or being run).
    # Disable DEVELOPMENT_INLINE_JOBS to debug :)
    queue = 'match_notify'
    previous_jobs = ApplicationJob.remove_delayed_jobs queue do |job|
      payload = job.payload_object
      # Remove the similar emails about to be sent
      [payload.object, payload.method_name] == [MatchMailerService, :notify_status] &&
        payload.args.first == match
    end

    # Fetch the oldest status from the previous jobs
    old_status = previous_jobs.first&.payload_object&.args&.last
    old_status ||= previous_status

    # Reschedule a new email, if needed.
    if match.status != old_status
      # Use DelayedJob (instead of the abstract layer, ActiveJob) because it’s easier to filter the payload object
      delay(run_at: 1.minute.from_now, queue: queue).notify_status(match, old_status)
    end
  end

  def self.notify_status(match, previous_status)
    UserMailer.notify_match_status(match, previous_status)&.deliver_later

    # Notify everyone if the match is being taken care of *now*
    if should_notify_everyone(previous_status, match.status)
      # Notify the company
      CompanyMailer.notify_taking_care(match).deliver_later
    end
    if match.status == :done_not_reachable
      CompanyMailer.notify_not_reachable(match).deliver_later
    end
  end

  def self.should_notify_everyone(old_status, new_status)
    not_taken_care_of = %w[quo not_for_me]
    taken_care_of = %w[taking_care done]

    old_status.in?(not_taken_care_of) && new_status.in?(taken_care_of)
  end
end
