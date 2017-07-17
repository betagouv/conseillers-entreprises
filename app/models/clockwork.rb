# frozen_string_literal: true

require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler { |_job, _time| AdminMailersService.send_statistics_email }

  every(1.week, 'send_statistics_email', at: 'Monday 09:30')
end
