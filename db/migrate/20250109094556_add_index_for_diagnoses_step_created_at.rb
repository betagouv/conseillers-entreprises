class AddIndexForDiagnosesStepCreatedAt < ActiveRecord::Migration[7.2]
  def change
    add_index :diagnoses, [:step, :created_at]
  end
end
