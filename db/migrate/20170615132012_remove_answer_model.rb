# frozen_string_literal: true

class RemoveAnswerModel < ActiveRecord::Migration[5.1]
  def up
    remove_column :questions, :answer_id
    remove_column :assistances, :answer_id
    drop_table :answers
  end

  def down
    create_table :answers do |t|
      t.string :label
      t.references :question, foreign_key: true

      t.timestamps
    end
    add_reference :assistances, :answer, foreign_key: true
    add_reference :questions, :answer, foreign_key: true
  end
end
