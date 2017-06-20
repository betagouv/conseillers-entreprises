# frozen_string_literal: true

class AddEmailSpecificSentenceToAssistance < ActiveRecord::Migration[5.1]
  def change
    add_column :assistances, :email_specific_sentence, :text
  end
end
