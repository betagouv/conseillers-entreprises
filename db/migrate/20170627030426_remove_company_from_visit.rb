# frozen_string_literal: true

class RemoveCompanyFromVisit < ActiveRecord::Migration[5.1]
  def change
    remove_reference :visits, :company, foreign_key: true
  end
end
