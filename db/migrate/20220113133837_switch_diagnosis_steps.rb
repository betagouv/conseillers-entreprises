class SwitchDiagnosisSteps < ActiveRecord::Migration[6.1]
  def change
    diagnoses_needs = Diagnosis.where(step: 'contact')
    diagnoses_visit = Diagnosis.where(step: 'needs')

    diagnoses_needs.map { |n| n.update(step: 'needs') }
    diagnoses_visit.map { |n| n.update(step: 'contact') }
  end
end
