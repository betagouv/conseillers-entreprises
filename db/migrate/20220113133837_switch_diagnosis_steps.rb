class SwitchDiagnosisSteps < ActiveRecord::Migration[6.1]
  def change
    diagnoses_needs = Diagnosis.where(step: 'contact')
    diagnoses_visit = Diagnosis.where(step: 'needs')

    diagnoses_needs.update_all(step: 'needs')
    diagnoses_visit.update_all(step: 'contact')
  end
end
