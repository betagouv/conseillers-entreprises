# frozen_string_literal: true

class RemoveExpertIdFromAssistance < ActiveRecord::Migration[5.1]
  def change
    remove_reference :assistances, :expert, foreign_key: true
  end
end
