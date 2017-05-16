# frozen_string_literal: true

class Assistance < ApplicationRecord
  belongs_to :answer

  validates :answer, :description, presence: true
end
