class AddNewFieldsToSolicitation < ActiveRecord::Migration[6.0]
  def change
    add_column :solicitations, :requested_help_amount, :string
    add_column :solicitations, :location, :string
  end
end
