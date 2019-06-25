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

  every(1.day, 'send_daily_change_updates', at: '9:00') do
    UserDailyChangeUpdateMailerService.delay.send_daily_change_updates
  end
end
