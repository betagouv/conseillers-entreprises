# frozen_string_literal: true

class RemoveLocalisationBooleansFromExpert < ActiveRecord::Migration[5.1]
  def change
    remove_column :experts, :on_maubeuge, :boolean, default: false, null: false
    remove_column :experts, :on_valenciennes_cambrai, :boolean, default: false, null: false
    remove_column :experts, :on_lens, :boolean, default: false, null: false
    remove_column :experts, :on_calais, :boolean, default: false, null: false
    remove_column :experts, :on_boulogne, :boolean, default: false, null: false
  end
end
