# frozen_string_literal: true

class RenameHappenedAtToHappenedOnInVisit < ActiveRecord::Migration[5.1]
  def change
    rename_column :visits, :happened_at, :happened_on
  end
end
