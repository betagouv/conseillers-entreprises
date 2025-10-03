class CreateTihQuestions < ActiveRecord::Migration[7.2]
  def up
    change_column :subject_answers, :filter_value, :string

    tih_theme = Theme.find_by(id: 54)
    if tih_theme.present?
      tih_theme.subjects.each do |subject|
        tih_question = subject.subject_questions.create(key: 'mode_contact_privilegie')
      end
    end
  end

  def down
    change_column :subject_answers, :filter_value, :boolean

    tih_theme = Theme.find_by(id: 54)
    if tih_theme.present?
      SubjectQuestion.where(subject_id: tih_theme.subject_ids).destroy_all
    end
  end
end
