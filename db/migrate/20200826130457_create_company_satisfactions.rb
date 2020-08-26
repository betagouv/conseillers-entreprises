class CreateCompanySatisfactions < ActiveRecord::Migration[6.0]
  def change
    create_table :company_satisfactions do |t|
      t.boolean :contacted_by_expert
      t.boolean :useful_exchange
      t.text :comment
      t.references :need, null: false, foreign_key: true

      t.timestamps
    end
  end
end
