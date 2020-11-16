class CreateRemindersActions < ActiveRecord::Migration[6.0]
  def change
    create_table :reminders_actions do |t|
      t.references :need, null: false, foreign_key: true
    end
    create_enum "actions_categories", %w[poke recall warn]
    add_column :reminders_actions, :category, :actions_categories, null: false
    add_index :reminders_actions, :category
    add_index :reminders_actions, [:need_id, :category], unique: true
  end
end
