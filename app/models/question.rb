# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :assistances
  belongs_to :category

  validates :category, presence: true

  def to_s
    label
  end
end
