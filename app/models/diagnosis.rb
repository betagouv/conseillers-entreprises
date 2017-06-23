# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :visit

  has_many :diagnosed_needs
  accepts_nested_attributes_for :diagnosed_needs

  validates :visit, presence: true

  scope :of_visit, (->(visit) { where(visit: visit) })
end
