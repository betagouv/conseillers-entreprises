# frozen_string_literal: true

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.max_attempts = 1
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))

Delayed::Worker.default_priority = 10

# Fail at startup if method does not exist instead of later in a background job
[[ExceptionNotifier, :notify_exception]].each do |object, method_name|
  next if object.respond_to?(method_name, true)
  raise NoMethodError, "undefined method `#{method_name}' for #{object.inspect}"
end

# Call exception notification
Delayed::Job.class_eval do
  def error(_job, exception)
    ExceptionNotifier.notify_exception(exception)
  end
end
