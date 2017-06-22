# frozen_string_literal: true

class CreateDiagnosedNeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :diagnosed_needs do |t|
      t.references :diagnosis, foreign_key: true
      t.string :question_label
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
