class AddSolicitationToDiagnoses < ActiveRecord::Migration[6.0]
  def change
    add_reference :diagnoses, :solicitation, foreign_key: true
  end
end
