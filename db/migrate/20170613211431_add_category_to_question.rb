# frozen_string_literal: true

class AddCategoryToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_reference :questions, :category, foreign_key: true
  end
end
