class AddAppInfoToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :app_info, :jsonb, default: {}
  end
end
