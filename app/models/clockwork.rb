require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.week, 'send_app_administrators_statistics_email', at: 'Monday 07:30') do
    AdminMailersService.delay.send_statistics_email
  end
  every(1.week, 'send_experts_reminders', at: 'Tuesday 9:00') do
    ExpertReminderService.delay.send_reminders
  end
  every(1.day, 'send_newsletter_subscription_emails', at: ('4:41')) do
    CompanyMailerService.delay.send_newsletter_subscription_emails
  end
  every(1.day, 'send_satisfaction_emails', at: ('5:41')) do
    CompanyMailerService.delay.send_satisfaction_emails
  end
  every(1.day, 'update_solicitations_code_region', at: ('3:41')) do
    `rake update_solicitations_code_region`
  end
  every(1.day, 'auto_archive_old_matches', at: ('2:41')) do
    `rake auto_archive_old_matches`
  end
end
