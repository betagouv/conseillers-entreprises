# frozen_string_literal: true

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.max_attempts = 1

Delayed::Worker.default_priority = 10
