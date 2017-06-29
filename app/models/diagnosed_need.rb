# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question
  has_many :assistances, through: :question

  validates :diagnosis, presence: true
end
