class ReplaceAbandonedEmailSentWithRemindersAction < ActiveRecord::Migration[7.0]
  def change
    up_only do
      Need.where(abandoned_email_sent: true).find_each do |need|
        need.reminders_actions.create(category: 'abandon')
      end
    end
  end
end
