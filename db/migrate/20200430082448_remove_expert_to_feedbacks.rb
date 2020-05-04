class RemoveExpertToFeedbacks < ActiveRecord::Migration[6.0]
  def change
    remove_column :feedbacks, :expert_id
  end
end
