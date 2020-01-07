require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.week, 'send_app_administrators_statistics_email', at: 'Monday 07:30') do
    AdminMailersService.send_statistics_email.deliver_later
  end

  every(1.week, 'send_experts_reminders', at: 'Tuesday 9:00') do
    ExpertReminderService.send_reminders.deliver_later
  end
end
