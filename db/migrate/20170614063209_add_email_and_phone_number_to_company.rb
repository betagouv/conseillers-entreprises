# frozen_string_literal: true

class AddEmailAndPhoneNumberToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :email, :string
    add_column :companies, :phone_number, :string
  end
end
