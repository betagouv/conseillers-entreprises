# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :contacts

  validates :name, presence: true

  def to_s
    name
  end

  def name_short
    name.first(40)
  end
end
