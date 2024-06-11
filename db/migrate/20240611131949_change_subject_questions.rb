class ChangeSubjectQuestions < ActiveRecord::Migration[7.0]
  def change
    rename_table('additional_subject_questions', 'subject_questions')
    rename_table('institution_filters', 'subject_answers')
    rename_column('subject_answers', 'institution_filtrable_type', 'subject_questioned_type')
    rename_column('subject_answers', 'institution_filtrable_id', 'subject_questioned_id')
    rename_column('subject_answers', 'additional_subject_question_id', 'subject_question_id')

    create_table :grouped_subject_answers do |t|
      t.references :institution, null: false, foreign_key: true, index: true
      t.references :company_satisfaction, null: false, foreign_key: true, index: true
      t.references :expert, null: false, foreign_key: true, index: true
      t.datetime :seen_at, precision: nil

      t.timestamps
    end
  end
end
