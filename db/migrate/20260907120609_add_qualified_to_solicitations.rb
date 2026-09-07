class AddQualifiedToSolicitations < ActiveRecord::Migration[8.1]
  def change
    add_column :solicitations, :qualified, :boolean
    add_column :solicitations, :qualification_details, :string
    add_column :solicitations, :qualified_at, :datetime
  end
end
