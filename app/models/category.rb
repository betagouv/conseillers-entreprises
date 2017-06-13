# frozen_string_literal: true

class Category < ApplicationRecord
  validates :label, presence: true, uniqueness: true

  def to_s
    label
  end
end
