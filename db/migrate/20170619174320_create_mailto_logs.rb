# frozen_string_literal: true

class CreateMailtoLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :mailto_logs do |t|
      t.references :question, foreign_key: true
      t.references :visit, foreign_key: true
      t.references :assistance, foreign_key: true

      t.timestamps
    end
  end
end
