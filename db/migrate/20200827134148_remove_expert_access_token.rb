class RemoveExpertAccessToken < ActiveRecord::Migration[6.0]
  def change
    remove_column :experts, :access_token, :string
  end
end
