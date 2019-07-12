class AddRemindersNotesToExperts < ActiveRecord::Migration[5.2]
  def change
    add_column :experts, :reminders_notes, :text
  end
end
