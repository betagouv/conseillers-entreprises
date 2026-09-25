class AddScopesToApiKeys < ActiveRecord::Migration[8.1]
  def change
    create_enum :api_key_scope, %w[qualification]
    add_column :api_keys, :scopes, :api_key_scope, array: true, null: false, default: []
  end
end
