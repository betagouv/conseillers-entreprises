class AddCountsToRemindersRegisters < ActiveRecord::Migration[7.0]
  def change
    add_column :reminders_registers, :expired_count, :integer, default: 0
  end
end
