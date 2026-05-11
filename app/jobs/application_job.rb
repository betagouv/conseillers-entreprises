class ApplicationJob < ActiveJob::Base
  retry_on Net::SMTPServerBusy

  class LowPriority < self
    queue_as :low_priority
  end
end
