class AddBannedToSolicitations < ActiveRecord::Migration[6.1]
  def change
    add_column :solicitations, :banned, :boolean, default: false
  end
end
