class AddExcludedFromQualificationToSubjects < ActiveRecord::Migration[8.1]
  def change
    add_column :subjects, :excluded_from_qualification, :boolean, default: false, null: false

    up_only do
      Cooperation.find(12).subjects.update_all(excluded_from_qualification: true)
    end
  end
end
