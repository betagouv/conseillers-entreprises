class AddFullNameToSolicitation < ActiveRecord::Migration[6.0]
  def change
    add_column :solicitations, :full_name, :string
  end
end
