class AddFlagsToDiagnosis < ActiveRecord::Migration[6.0]
  def change
    add_column :diagnoses, :newsletter_subscription_email_sent, :boolean, null: false, default: false # bitfield
    add_column :diagnoses, :satisfaction_email_sent, :boolean, null: false, default: false # bitfield
  end
end
