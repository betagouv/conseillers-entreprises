class AddFlagsToExperts < ActiveRecord::Migration[6.0]
  def change
    add_column :experts, :flags, :jsonb, default: {}
  end
end
