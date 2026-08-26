class RemoveIntelligentRetention < ActiveRecord::Migration[8.1]
  def change
    remove_column :needs, :retention_sent_at, :datetime

    drop_table :email_retentions do |t|
      t.string :email_subject, null: false
      t.text :first_paragraph, null: false
      t.bigint :first_subject_id, null: false
      t.string :first_subject_label, null: false
      t.bigint :second_subject_id, null: false
      t.string :second_subject_label, null: false
      t.bigint :subject_id, null: false
      t.integer :waiting_time, null: false
      t.timestamps

      t.index :first_subject_id
      t.index :second_subject_id
      t.index :subject_id, unique: true
    end
  end
end
