class DescriptionNotNull < ActiveRecord::Migration[8.1]
  def change
    up_only do
      InstitutionSubject.where(description: nil).update_all(description: "")
    end

    change_column_default :institutions_subjects, :description, from: nil, to: ""
    change_column_null :institutions_subjects, :description, false
  end
end
