class UpdateDiagnosisNewsletterField < ActiveRecord::Migration[6.1]
  def change
    remove_column :diagnoses, :newsletter_subscription_email_sent, :boolean, default: false
    add_column :diagnoses, :retention_email_sent, :boolean, default: false
  end
end
