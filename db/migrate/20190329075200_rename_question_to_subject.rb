class RenameQuestionToSubject < ActiveRecord::Migration[5.2]
  def change
    rename_table :questions, :subjects
    rename_column :skills, :question_id, :subject_id
    rename_column :diagnosed_needs, :question_id, :subject_id
  end
end
