class TweakDiagnosisBelongsTos < ActiveRecord::Migration[6.0]
  def change
    change_column_null :diagnoses, :facility_id, false # Diagnosis.facility should already be not null
    change_column_null :diagnoses, :advisor_id, true # Diagnosis.advisor is becoming nullable for #940
  end
end
