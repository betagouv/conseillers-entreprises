# frozen_string_literal: true

class AddStepToDiagnosis < ActiveRecord::Migration[5.1]
  def change
    add_column :diagnoses, :step, :integer, default: 1
  end
end
