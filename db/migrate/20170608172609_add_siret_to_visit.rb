# frozen_string_literal: true

class AddSiretToVisit < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :siret, :string
  end
end
