class CopyVisitFieldsToDiagnosis < ActiveRecord::Migration[5.2]
  def up
    Diagnosis.all.includes(:visit).each do |d|
      v = d.visit
      d.update_columns(
        facility_id: v.facility_id,
        advisor_id: v.advisor_id,
        visitee_id: v.visitee_id,
        happened_on: v.happened_on
      )
      puts d
    end
  end
end
