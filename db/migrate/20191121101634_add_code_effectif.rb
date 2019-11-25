class AddCodeEffectif < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :code_effectif, :string
    add_column :facilities, :code_effectif, :string
  end
end
