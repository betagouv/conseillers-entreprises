class RemoveDeactivatedUsers < ActiveRecord::Migration[6.0]
  def change
    up_only do
      User.where.not(deactivated_at: nil).not_deleted.destroy_all
    end
    remove_column :users, :deactivated_at, :datetime
  end
end
