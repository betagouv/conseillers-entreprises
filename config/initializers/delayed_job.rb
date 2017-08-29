# frozen_string_literal: true

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.max_attempts = 1

Delayed::Worker.default_priority = 10

# Fail at startup if method does not exist instead of later in a background job
[[ExceptionNotifier, :notify_exception]].each do |object, method_name|
  next if object.respond_to?(method_name, true)
  raise NoMethodError, "undefined method `#{method_name}' for #{object.inspect}"
end

# Chain delayed job's handle_failed_job method to do exception notification
Delayed::Worker.class_eval do
  def handle_failed_job_with_notification(job, error)
    handle_failed_job_without_notification(job, error)
    ExceptionNotifier.notify_exception(error)
  end

  alias_method_chain :handle_failed_job, :notification
end
