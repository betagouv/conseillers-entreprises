require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.day, 'revoke_api_keys', at: ('2:00'), if: -> (t) { t.day == 1 }) do
    ApiKeysManagement.delay.batch_revoke
  end
  every(1.week, 'send_app_administrators_statistics_email', at: 'Monday 07:30') do
    AdminMailersService.delay.send_statistics_email
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
  every(1.day, 'send_failed_jobs_email', at: '10:00') do
    AdminMailersService.delay.send_failed_jobs
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
  every(1.day, 'relaunch_solicitations', at: ('12:00')) do
    SolicitationsRelaunchService.perform
  end
  if Rails.env == 'production'
    every(1.day, 'generate_quarterly_reports', at: '01:00', if: -> (t) { t.day == 14 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }) do
      Antenne.find_in_batches(batch_size: 10) do |antennes|
        QuarterlyReportService.delay(queue: :low_priority).generate_reports(antennes)
      end
    end
    every(1.day, 'send_quarterly_reports_emails', at: '08:00', if: -> (t) { t.day == 15 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }) do
      QuarterlyReportService.delay(queue: :low_priority).send_emails
    end
  end
end
