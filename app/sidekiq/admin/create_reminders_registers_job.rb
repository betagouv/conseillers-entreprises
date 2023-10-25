class Admin::CreateRemindersRegistersJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    RemindersService.create_reminders_registers
  end
end
