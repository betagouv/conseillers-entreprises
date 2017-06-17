# frozen_string_literal: true

class RemoveSiretFromVisit < ActiveRecord::Migration[5.1]
  def up
    remove_column :visits, :siret
  end

  def down
    add_column :visits, :siret, :string
  end
end
