# frozen_string_literal: true

class AddQuestionToAssistance < ActiveRecord::Migration[5.1]
  def change
    add_reference :assistances, :question, foreign_key: true
  end
end
