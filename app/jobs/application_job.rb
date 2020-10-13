# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  extend JobExtensions::RemoveDelayedJobs
end
