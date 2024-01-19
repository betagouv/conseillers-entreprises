class Admin::SendFailedJobsJob < ApplicationJob
  queue_as :low_priority

  def perform
    failed_jobs = Sidekiq::Failures::FailureSet.new.map{ |j| j.item }.as_json
    AdminMailer.failed_jobs(failed_jobs).deliver_later(queue: 'low_priority')
  end
end
