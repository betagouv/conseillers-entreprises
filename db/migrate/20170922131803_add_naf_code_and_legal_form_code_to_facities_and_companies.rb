# frozen_string_literal: true

class AddNafCodeAndLegalFormCodeToFacitiesAndCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :legal_form_code, :string
    add_column :facilities, :naf_code, :string
  end
end
