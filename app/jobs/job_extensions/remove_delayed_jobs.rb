module JobExtensions
  module RemoveDelayedJobs
    # Remove existing delayed jobs in the given queue, matching the
    def remove_delayed_jobs(queue = nil, &block)
      # Lock all jobs in the queue
      lock_name = "remove-jobs-#{SecureRandom.base64(16)}"
      Delayed::Job
        .for_queues(queue)
        .where(locked_at: nil)
        .update_all(locked_at: Time.now, locked_by: lock_name)

      # Find which jobs to strike
      locked_jobs = Delayed::Job.where(locked_by: lock_name)
      removed_jobs = if block.present?
        locked_jobs.filter(&block)
      else
        locked_jobs
      end
      # implementation caveat:
      # * locked_jobs is an ActiveRecord::Relation, queried each time.
      # * removed_jobs on the other hand is an actual Array

      # Actually delete it
      removed_jobs.each(&:destroy)

      # Unlock remaining locked jobs
      locked_jobs.update_all(locked_at: nil, locked_by: nil)

      removed_jobs
    end
  end
end
