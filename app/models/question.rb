# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :assistances
  belongs_to :category

  def to_s
    label
  end
end
