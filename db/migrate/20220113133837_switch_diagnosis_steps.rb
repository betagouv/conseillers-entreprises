class SwitchDiagnosisSteps < ActiveRecord::Migration[6.1]
  def change
    diagnoses_needs = Diagnosis.where(step: 3)
    diagnoses_visit = Diagnosis.where(step: 2)

    diagnoses_needs.each { |n| n.update(step: 3) }
    diagnoses_visit.each { |n| n.update(step: 2) }
  end
end
