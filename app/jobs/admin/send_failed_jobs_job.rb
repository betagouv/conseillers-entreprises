class Admin::SendFailedJobsJob < ApplicationJob
  queue_as :low_priority

  def perform
    failed_jobs_count = Sidekiq::Failures.count
    AdminMailer.failed_jobs(failed_jobs_count).deliver_later(queue: 'low_priority')
  end
end
