# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :contacts

  validates :name, presence: true

  scope :ordered_by_name, (-> { order(:name) })

  def to_s
    name
  end

  def name_short
    name.first(40)
  end
end
