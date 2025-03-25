class AddCodeSafirToAntennes < ActiveRecord::Migration[7.2]
  def change
    add_column :antennes, :code_safir, :string
  end
end
