class CreateLandingTopics < ActiveRecord::Migration[5.2]
  def change
    create_table :landing_topics do |t|
      t.string :title
      t.text :description
      t.integer :landing_sort_order

      t.timestamps
    end

    add_reference :landing_topics, :landing, foreign_key: true
  end
end
