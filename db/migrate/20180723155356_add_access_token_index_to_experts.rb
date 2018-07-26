class AddAccessTokenIndexToExperts < ActiveRecord::Migration[5.2]
  def change
    add_index :experts, :access_token
  end
end
