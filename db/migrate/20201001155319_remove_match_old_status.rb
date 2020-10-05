class RemoveMatchOldStatus < ActiveRecord::Migration[6.0]
  def change
    remove_column :matches, :old_status, :integer
  end
end
