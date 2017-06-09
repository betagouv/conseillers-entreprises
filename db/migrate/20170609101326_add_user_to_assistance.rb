# frozen_string_literal: true

class AddUserToAssistance < ActiveRecord::Migration[5.1]
  def change
    add_reference :assistances, :user, foreign_key: true
  end
end
