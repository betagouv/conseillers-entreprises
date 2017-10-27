# frozen_string_literal: true

class RemoveEmailAndPhoneNumberFromCompany < ActiveRecord::Migration[5.1]
  def change
    remove_column :companies, :email, :string
    remove_column :companies, :phone_number, :string
  end
end
