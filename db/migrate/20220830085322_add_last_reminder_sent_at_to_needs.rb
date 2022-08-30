class AddLastReminderSentAtToNeeds < ActiveRecord::Migration[7.0]
  def change
    add_column :needs, :last_reminder_sent_at, :datetime
  end
end
