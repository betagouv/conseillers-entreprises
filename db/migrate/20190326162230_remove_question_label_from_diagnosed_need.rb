class RemoveQuestionLabelFromDiagnosedNeed < ActiveRecord::Migration[5.2]
  def change
    remove_column :diagnosed_needs, :question_label, :string
  end
end
