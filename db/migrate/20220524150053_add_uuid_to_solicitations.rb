class AddUuidToSolicitations < ActiveRecord::Migration[7.0]
  def change
    add_column :solicitations, :uuid, :uuid
    add_index :solicitations, :uuid
  end
end
