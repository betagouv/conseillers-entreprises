# frozen_string_literal: true

class RemoveMailtoLog < ActiveRecord::Migration[5.1]
  def up
    drop_table :mailto_logs
  end

  def down
    create_table :mailto_logs do |t|
      t.references :question, foreign_key: true
      t.references :visit, foreign_key: true
      t.references :assistance, foreign_key: true

      t.timestamps
    end
  end
end
