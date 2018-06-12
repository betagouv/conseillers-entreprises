class AddReadableLocalityToFacility < ActiveRecord::Migration[5.1]
  def change
    add_column :facilities, :readable_locality, :string
  end
end
