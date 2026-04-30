class RemoveSupportSubject < ActiveRecord::Migration[8.1]
  def change
    up_only do
      support_subjects = Subject.where(is_support: true)
      raise "Several support subjects detected, abort" if support_subjects.many?

      support_subjects.each { it.archive! }
    end

    remove_column :subjects, :is_support, :boolean, default: false, null: false
  end
end
