class AddInterviewSortOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :interview_sort_order, :integer
    add_column :categories, :interview_sort_order, :integer
  end
end
