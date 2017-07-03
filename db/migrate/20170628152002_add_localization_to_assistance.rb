# frozen_string_literal: true

class AddLocalizationToAssistance < ActiveRecord::Migration[5.1]
  def change
    add_column :assistances, :for_maubeuge, :boolean, default: false, null: false
    add_column :assistances, :for_valenciennes_cambrai, :boolean, default: false, null: false
    add_column :assistances, :for_lens, :boolean, default: false, null: false
    add_column :assistances, :for_calais, :boolean, default: false, null: false
  end
end
