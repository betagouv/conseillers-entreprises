class AddAbandonedAtToNeeds < ActiveRecord::Migration[7.0]
  def change
    add_column :needs, :abandoned_at, :datetime
  end
end
