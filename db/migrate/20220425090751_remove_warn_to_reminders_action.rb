class RemoveWarnToRemindersAction < ActiveRecord::Migration[6.1]
  def up
    rename_column :reminders_actions, :category, :old_category
    change_column_null :reminders_actions, :old_category, true
    add_column :reminders_actions, :category, :integer

    RemindersAction.where(old_category: 'warn').destroy_all
    RemindersAction.where(old_category: 'poke').update_all(category: 1)
    RemindersAction.where(old_category: 'recall').update_all(category: 2)

    change_column_null :reminders_actions, :category, false
    add_index :reminders_actions, [:need_id, :category], unique: true
    remove_column :reminders_actions, :old_category
    drop_enum :actions_categories
  end

  def down
    create_enum "actions_categories", %w[poke recall warn]
    add_column :reminders_actions, :old_category, :actions_categories
    change_column_null :reminders_actions, :category, true

    RemindersAction.where(category: 1).update_all(old_category: 'poke')
    RemindersAction.where(category: 2).update_all(old_category: 'recall')

    remove_column :reminders_actions, :category
    rename_column :reminders_actions, :old_category, :category
    change_column_null :reminders_actions, :category, false
    add_index :reminders_actions, [:need_id, :category], unique: true
  end
end
