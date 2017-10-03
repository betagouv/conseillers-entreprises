# frozen_string_literal: true

class AddCraftmanBooleansToInstitution < ActiveRecord::Migration[5.1]
  def change
    add_column :institutions, :qualified_for_commerce, :boolean, default: true, null: false
    add_column :institutions, :qualified_for_artisanry, :boolean, default: true, null: false
  end
end
