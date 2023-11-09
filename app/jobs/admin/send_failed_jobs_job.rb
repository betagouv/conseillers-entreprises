class Admin::SendFailedJobsJob < ApplicationJob
  queue_as :low_priority

  def perform
    failed_jobs = Sidekiq::DeadSet.new.map{ |job| job }.as_json
    AdminMailer.failed_jobs(failed_jobs).deliver_later(queue: 'low_priority')
  end
end
