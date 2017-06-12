# frozen_string_literal: true

class Assistance < ApplicationRecord
  belongs_to :answer
  belongs_to :user

  validates :answer, :description, presence: true
end
