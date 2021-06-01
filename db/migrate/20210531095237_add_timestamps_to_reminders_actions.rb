class AddTimestampsToRemindersActions < ActiveRecord::Migration[6.1]
  def change
    # add new column but allow null values
    add_timestamps :reminders_actions, null: true

    # backfill existing records with created_at and updated_at
    # values that make clear that the records are faked
    long_ago = DateTime.new(2000, 1, 1)
    RemindersAction.update_all(created_at: long_ago, updated_at: long_ago)

    # change to not null constraints
    change_column_null :reminders_actions, :created_at, false
    change_column_null :reminders_actions, :updated_at, false
  end
end
