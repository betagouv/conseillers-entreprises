class ChangeSatisfactionEmailSentToNeed < ActiveRecord::Migration[6.0]
  def change
    remove_column :diagnoses, :satisfaction_email_sent, :boolean
    add_column :needs, :satisfaction_email_sent, :boolean
  end
end
