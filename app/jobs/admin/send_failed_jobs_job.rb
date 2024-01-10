class Admin::SendFailedJobsJob < ApplicationJob
  queue_as :low_priority

  def perform
    count = Sidekiq::Failures::FailureSet.new.count
    return if count.zero?
    AdminMailer.failed_jobs(count).deliver_later(queue: 'low_priority')
  end
end
