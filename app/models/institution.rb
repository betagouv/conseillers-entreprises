# frozen_string_literal: true

class Institution < ApplicationRecord
  has_many :experts

  validates :name, presence: true

  def to_s
    name
  end
end
