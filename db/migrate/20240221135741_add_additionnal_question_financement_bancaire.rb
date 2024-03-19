class AddAdditionnalQuestionFinancementBancaire < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.test?
      new_question = AdditionalSubjectQuestion.create!(key: 'financement_bancaire_envisage', subject_id: 55, position: 2)
      AdditionalSubjectQuestion.find(5).update(position: 3)

      adie = Institution.find_by(slug: 'adie')
      initiative = Institution.find_by(slug: 'initiative-france')
      bpi = Institution.find_by(slug: 'bpifrance')
      bdf = Institution.find_by(slug: 'banque-de-france')
      adie.institution_filters.create!(additional_subject_question_id: new_question.id, filter_value: true)
      initiative.institution_filters.create!(additional_subject_question_id: new_question.id, filter_value: true)
      bpi.institution_filters.create!(additional_subject_question_id: new_question.id, filter_value: true)
      bdf.institution_filters.create!(additional_subject_question_id: new_question.id, filter_value: true)
    end
  end
end
