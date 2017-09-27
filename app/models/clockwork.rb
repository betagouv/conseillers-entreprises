# frozen_string_literal: true

require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.week, 'send_statistics_email', at: 'Monday 09:30') { AdminMailersService.delay.send_statistics_email }
  every(1.week, 'send_experts_reminders', at: 'Monday 09:30') { ExpertReminderService.delay.send_reminders }
end
