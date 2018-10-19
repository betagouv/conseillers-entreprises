class AddIndexToExperts < ActiveRecord::Migration[5.2]
  def change
    add_index :experts, :email
  end
end
