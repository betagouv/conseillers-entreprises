class AddRelaunchToSolicitations < ActiveRecord::Migration[7.0]
  def change
    add_column :solicitations, :relaunch, :string
  end
end
