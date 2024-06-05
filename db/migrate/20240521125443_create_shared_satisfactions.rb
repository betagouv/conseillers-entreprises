class CreateSharedSatisfactions < ActiveRecord::Migration[7.0]
  def change
    create_table :shared_satisfactions do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :company_satisfaction, null: false, foreign_key: true, index: true
      t.references :expert, null: false, foreign_key: true, index: true
      t.datetime :seen_at, precision: nil

      t.timestamps
    end
    add_index :shared_satisfactions, [:user_id, :company_satisfaction_id, :expert_id], unique: true, name: 'shared_satisfactions_references_index'
  end
end
