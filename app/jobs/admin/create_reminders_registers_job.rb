class Admin::CreateRemindersRegistersJob < ApplicationJob
  queue_as :low_priority

  def perform
    RemindersService.new.create_reminders_registers
  end
end
