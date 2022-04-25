class RemoveWarnToRemindersAction < ActiveRecord::Migration[6.1]
  def change
    RemindersAction.where(category: 'warn').destroy_all
    remove_enum_value :actions_categories, "warn"
  end
end
