class AddRunNumberToReminderRegisters < ActiveRecord::Migration[7.0]
  def change
    add_column :reminders_registers, :run_number, :integer
    add_index :reminders_registers, [:run_number, :expert_id], unique: true
    up_only do
      RemindersRegister.all.group_by(&:expert).each do |experts_registers|
        run = 0
        experts_registers.last.sort_by(&:id).each do |register|
          register.update(run_number: run)
          run += 1
        end
      end
      change_column :reminders_registers, :run_number, :integer, null: false
    end
  end
end
