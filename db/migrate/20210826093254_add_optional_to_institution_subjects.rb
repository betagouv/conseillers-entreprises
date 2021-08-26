class AddOptionalToInstitutionSubjects < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions_subjects, :optional, :boolean, default: false
  end
end
