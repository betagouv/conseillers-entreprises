class RemoveExpertFieldToMatch < ActiveRecord::Migration[6.0]
  def change
    remove_column :matches, :expert_full_name, :string
    remove_column :matches, :expert_institution_name, :string
  end
end
