class AddAnswerIdToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_reference :questions, :answer, foreign_key: true
  end
end
