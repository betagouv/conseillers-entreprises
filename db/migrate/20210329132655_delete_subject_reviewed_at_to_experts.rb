class DeleteSubjectReviewedAtToExperts < ActiveRecord::Migration[6.0]
  def change
    remove_column :experts, :subjects_reviewed_at, :datetime
  end
end
