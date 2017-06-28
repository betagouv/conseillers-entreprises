# frozen_string_literal: true

class RenamePostalCodeIntoCityCode < ActiveRecord::Migration[5.1]
  def change
    rename_column :facilities, :postal_code, :city_code
  end
end
