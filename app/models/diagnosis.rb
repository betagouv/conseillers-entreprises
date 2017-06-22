# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :visit

  validates :visit, presence: true
end
