class AddInseeCodeToSolicitations < ActiveRecord::Migration[7.2]
  def change
    add_column :solicitations, :insee_code, :string
  end
end
