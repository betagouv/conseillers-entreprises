class CreateReminderRegisters < ActiveRecord::Migration[7.0]
  def change
    create_table :reminders_registers do |t|
      t.integer :category, default: 0, null: false
      t.integer :basket
      t.references :expert, null: false, foreign_key: true
      t.boolean :processed, default: false, null: false

      t.timestamps
    end
  end
end
