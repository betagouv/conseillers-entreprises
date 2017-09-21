# frozen_string_literal: true

class AddAccessTokenToExpert < ActiveRecord::Migration[5.1]
  def change
    add_column :experts, :access_token, :string
  end
end
