class AddSiretToSolicitations < ActiveRecord::Migration[5.2]
  def change
    add_column :solicitations, :siret, :string
  end
end
