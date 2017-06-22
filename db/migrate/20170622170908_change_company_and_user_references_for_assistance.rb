# frozen_string_literal: true

class ChangeCompanyAndUserReferencesForAssistance < ActiveRecord::Migration[5.1]
  def up
    remove_column :assistances, :company_id
    remove_column :assistances, :user_id
    add_reference :assistances, :institution, foreign_key: true
    add_reference :assistances, :expert, foreign_key: true
  end

  def down
    remove_column :assistances, :institution_id
    remove_column :assistances, :expert_id
    add_reference :assistances, :company, foreign_key: true
    add_reference :assistances, :user, foreign_key: true
  end
end
