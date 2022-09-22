class DeleteAbandonedAtToNeeds < ActiveRecord::Migration[7.0]
  def change
    remove_column :needs, :abandoned_at, :datetime
    remove_column :needs, :last_chance_email_sent_at, :datetime
  end
end
