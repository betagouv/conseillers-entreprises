class ChangesSatisfactionnEmailSentDefaultForNeed < ActiveRecord::Migration[6.0]
  def change
    Need.where(satisfaction_email_sent: nil).update_all(satisfaction_email_sent: false)
    change_column :needs, :satisfaction_email_sent, :boolean, null: false, default: false
  end
end
