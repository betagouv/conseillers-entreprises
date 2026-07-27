class AddSubjectCanBeAutomated < ActiveRecord::Migration[8.1]
  def change
    add_column :subjects, :can_be_automated, :boolean, null: false, default: false
    up_only do
      Subject.not_archived.where.missing(:cooperations).update_all(can_be_automated: true)
    end
  end
end
