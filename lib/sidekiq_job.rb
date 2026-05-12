# frozen_string_literal: true

module SidekiqJob
  ## This is way more code that should be needed to get the current status of an ActiveJob running in Sidekiq.
  # @param job_class a subclass of ActiveJob::Base
  # @param record a subclass of ActiveRecord::Base
  # obtain the current status of a job started like this job_class.perform_later(record)
  # @return Hash with the following optional keys:
  #   - :queued_at if the job has been queued
  #   - :run_at if the job has been started
  #   if no job matching the parameters is found, returns an empty hash.
  #
  # Unfortunately, the mechanism here is mostly untestable, unless we actually use Sidekiq and redis in our tests.
  def self.status_for(job_class, item)
    work = Sidekiq::WorkSet.new
      .map{ |_process_id, _thread_id, work| work }
      .find do |work|
      job = work.job
      hash = job.args.first
      hash["job_class"] == job_class.to_s && hash.dig("arguments", 0, "_aj_globalid") == item.to_gid.uri.to_s
    end

    if work.present?
      return {
        enqueued_at: work.job.enqueued_at,
        run_at: work.run_at
      }
    end

    queue = Sidekiq::Queue.all.find{ it.name == job_class.queue_name }
    job = queue.find do |job|
      hash = job.args.first
      hash["job_class"] == job_class.to_s && hash.dig("arguments", 0, "_aj_globalid") == item.to_gid.uri.to_s
    end

    if job.present?
      return {
        enqueued_at: job.enqueued_at,
      }
    end

    return {}
  end
end
