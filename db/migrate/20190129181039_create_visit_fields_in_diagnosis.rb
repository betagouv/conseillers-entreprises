class CreateVisitFieldsInDiagnosis < ActiveRecord::Migration[5.2]
  def change
    add_reference :diagnoses, :advisor, foreign_key: { to_table: :users }
    add_reference :diagnoses, :visitee, foreign_key: { to_table: :contacts }
    add_reference :diagnoses, :facility, foreign_key: true
    add_column :diagnoses, :happened_on, :date
  end
end
