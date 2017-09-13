# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :assistances, dependent: :nullify
  has_many :diagnosed_needs, dependent: :nullify
  belongs_to :category

  validates :category, presence: true

  def to_s
    label
  end
end
