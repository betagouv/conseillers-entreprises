# frozen_string_literal: true

class AddDeletedAtToDiagnoses < ActiveRecord::Migration[5.1]
  def change
    add_column :diagnoses, :deleted_at, :datetime
    add_index :diagnoses, :deleted_at
  end
end
