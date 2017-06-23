# frozen_string_literal: true

class Institution < ApplicationRecord
  validates :name, presence: true

  def to_s
    name
  end
end
