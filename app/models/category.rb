# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :questions

  validates :label, presence: true, uniqueness: true

  default_scope { order(:interview_sort_order, :id) }

  def to_s
    label
  end
end
