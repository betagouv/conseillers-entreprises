class AddLastChanceEmailSentAtToNeeds < ActiveRecord::Migration[7.0]
  def change
    add_column :needs, :last_chance_email_sent_at, :datetime
  end
end
