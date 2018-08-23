# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :questions

  validates :label, presence: true, uniqueness: true

  def to_s
    label
  end
end
