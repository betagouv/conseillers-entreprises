class CreateQualifications < ActiveRecord::Migration[8.1]
  def change
    create_table :qualifications do |t|
      t.references :solicitation, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.boolean :qualified, null: false
      t.string :details
      t.datetime :qualified_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.text :feedback
      t.references :feedback_user, foreign_key: { to_table: :users, on_delete: :nullify }

      t.timestamps
    end

    remove_index :solicitations, :id, name: :index_solicitations_on_unqualified, where: "qualified IS NULL AND status = 3"
    remove_column :solicitations, :qualified, :boolean
    remove_column :solicitations, :qualification_details, :string
    remove_column :solicitations, :qualified_at, :datetime
  end
end
