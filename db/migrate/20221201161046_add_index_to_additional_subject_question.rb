class AddIndexToAdditionalSubjectQuestion < ActiveRecord::Migration[7.0]
  def change
    add_index :additional_subject_questions, [:subject_id, :key], unique: true, name: 'additional_subject_question_subject_key_index'
  end
end
