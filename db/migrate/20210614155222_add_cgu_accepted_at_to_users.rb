class AddCguAcceptedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :cgu_accepted_at, :datetime
  end
end
