# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  validates :diagnosis, presence: true
end
