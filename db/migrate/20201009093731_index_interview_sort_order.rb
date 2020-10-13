class IndexInterviewSortOrder < ActiveRecord::Migration[6.0]
  def change
    add_index :themes, :interview_sort_order
    add_index :subjects, :interview_sort_order
  end
end
