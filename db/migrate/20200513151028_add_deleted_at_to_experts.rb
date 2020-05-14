class AddDeletedAtToExperts < ActiveRecord::Migration[6.0]
  def change
    add_column :experts, :deleted_at, :datetime
    change_column_null :experts, :phone_number, true
  end
end
