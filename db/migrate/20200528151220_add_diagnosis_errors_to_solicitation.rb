class AddDiagnosisErrorsToSolicitation < ActiveRecord::Migration[6.0]
  def change
    add_column :solicitations, :prepare_diagnosis_errors_details, :jsonb, default: {}
  end
end
