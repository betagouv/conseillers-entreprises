# frozen_string_literal: true

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 15.minutes
Delayed::Worker.max_attempts = 2
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))

Delayed::Worker.default_priority = 10
