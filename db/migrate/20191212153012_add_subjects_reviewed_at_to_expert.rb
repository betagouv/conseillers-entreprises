class AddSubjectsReviewedAtToExpert < ActiveRecord::Migration[6.0]
  def change
    add_column :experts, :subjects_reviewed_at, :datetime
  end
end
