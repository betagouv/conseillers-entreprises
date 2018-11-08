class RemoveInstitutionFromExpert < ActiveRecord::Migration[5.2]
  def change
    remove_reference :experts, :institution, foreign_key: true
  end
end
