class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks do |t|
      t.text :description
      t.references :match, index: true, foreign_key: true

      t.timestamps
    end
  end
end
