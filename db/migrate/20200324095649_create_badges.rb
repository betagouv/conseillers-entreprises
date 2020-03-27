class CreateBadges < ActiveRecord::Migration[6.0]
  def change
    create_table :badges do |t|
      t.string :title, null: false
      t.string :color, null: false

      t.timestamps
    end
    create_join_table :badges, :solicitations
  end
end
