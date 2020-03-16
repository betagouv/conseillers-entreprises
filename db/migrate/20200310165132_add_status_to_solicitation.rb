class AddStatusToSolicitation < ActiveRecord::Migration[6.0]
  def change
    add_column :solicitations, :status, :integer, default: 0
  end
end
