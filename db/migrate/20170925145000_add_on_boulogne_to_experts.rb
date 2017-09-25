# frozen_string_literal: true

class AddOnBoulogneToExperts < ActiveRecord::Migration[5.1]
  def change
    add_column :experts, :on_boulogne, :boolean, default: false, null: false
  end
end
