class PreventNullQuestions < ActiveRecord::Migration[5.2]
  def change
    change_column_null :diagnosed_needs, :question_id, false
    change_column_null :assistances, :question_id, false
  end
end
