class RemoveBannedFromSolicitations < ActiveRecord::Migration[7.0]
  def change
    remove_column :solicitations, :banned, :boolean, default: false
  end
end
