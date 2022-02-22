class CreateQuarterlyData < ActiveRecord::Migration[6.1]
  def change
    create_table :quarterly_data do |t|
      t.date :start_date
      t.date :end_date
      t.references :antenne, null: false, foreign_key: true

      t.timestamps
    end
  end
end
