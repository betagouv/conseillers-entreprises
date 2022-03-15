require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.week, 'send_app_administrators_statistics_email', at: 'Monday 07:30') do
    AdminMailersService.delay.send_statistics_email
  end
  every(1.day, 'send_failed_jobs_email', at: '10:00') do
    AdminMailersService.delay.send_failed_jobs
  end
  every(1.week, 'send_experts_reminders', at: 'Tuesday 9:00') do
    ExpertReminderService.delay.send_reminders
  end
  every(1.week, 'delete_unused_users', at: 'sunday 9:00') do
    UnusedUsersService.delay.delete_users
  end
  every(1.week, 'anonymize_old_diagnoses', at: 'sunday 5:00') do
    `rake anonymize_old_diagnoses`
  end
  every(1.day, 'send_retention_emails', at: ('4:41')) do
    CompanyMailerService.delay.send_retention_emails
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
  if Rails.env == 'production'
    every(1.day, 'generate_quarterly_reports', at: '01:00', if: -> (t) { t.day == 14 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }) do
      QuarterlyReportService.delay.generate_reports
    end
  end
end
