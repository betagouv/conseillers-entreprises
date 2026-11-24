class AddQualificationFeedbackToSolicitations < ActiveRecord::Migration[8.1]
  def change
    add_column :solicitations, :qualification_feedback, :text
    add_reference :solicitations, :qualification_feedback_user, foreign_key: { to_table: :users, on_delete: :nullify }
  end
end
