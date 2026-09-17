class AddScopesToApiKeys < ActiveRecord::Migration[8.1]
  def change
    add_column :api_keys, :scopes, :string, array: true, null: false, default: []
  end
end
