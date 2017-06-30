# frozen_string_literal: true

class AddLocalizationToExpert < ActiveRecord::Migration[5.1]
  def change
    add_column :experts, :on_maubeuge, :boolean, default: false, null: false
    add_column :experts, :on_valenciennes_cambrai, :boolean, default: false, null: false
    add_column :experts, :on_lens, :boolean, default: false, null: false
    add_column :experts, :on_calais, :boolean, default: false, null: false
  end
end
