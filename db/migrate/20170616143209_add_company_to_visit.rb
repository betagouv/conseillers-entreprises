# frozen_string_literal: true

class AddCompanyToVisit < ActiveRecord::Migration[5.1]
  def change
    add_reference :visits, :company, foreign_key: true
  end
end
