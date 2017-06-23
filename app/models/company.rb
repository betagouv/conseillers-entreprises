# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true

  def to_s
    name
  end

  def name_short
    name.first(40)
  end
end
