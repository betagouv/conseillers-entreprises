class AdminMailerPreview < ActionMailer::Preview
  def failed_jobs
    jobs = Delayed::Backend::ActiveRecord::Job.where.not(failed_at: nil).as_json
    AdminMailer.failed_jobs(jobs)
  end
end
