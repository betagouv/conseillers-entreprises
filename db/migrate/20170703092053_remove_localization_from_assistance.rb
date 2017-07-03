# frozen_string_literal: true

class RemoveLocalizationFromAssistance < ActiveRecord::Migration[5.1]
  def change
    remove_column :assistances, :for_maubeuge, :boolean, default: false, null: false
    remove_column :assistances, :for_valenciennes_cambrai, :boolean, default: false, null: false
    remove_column :assistances, :for_lens, :boolean, default: false, null: false
    remove_column :assistances, :for_calais, :boolean, default: false, null: false
  end
end
