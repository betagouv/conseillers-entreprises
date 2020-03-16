class CreateLandingOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :landing_options do |t|
      t.string :slug
      t.text :description
      t.integer :landing_sort_order
    end

    add_reference :landing_options, :landing, foreign_key: true

    rename_column :solicitations, :needs, :options
  end
end
