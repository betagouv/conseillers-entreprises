class RemoveEmailSpecificSentenceFromAssistance < ActiveRecord::Migration[5.1]
  def change
    remove_column :assistances, :email_specific_sentence, :text
  end
end
