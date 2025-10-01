class ApplicationJob < ActiveJob::Base
  retry_on Net::SMTPServerBusy
end
