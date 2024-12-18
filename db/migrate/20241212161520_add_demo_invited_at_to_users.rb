class AddDemoInvitedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :demo_invited_at, :datetime
  end
end
