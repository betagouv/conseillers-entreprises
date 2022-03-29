class AddAbandonedEmailSendToNeeds < ActiveRecord::Migration[6.1]
  def change
    add_column :needs, :abandoned_email_sent, :boolean, default: false
  end
end
