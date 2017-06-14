# frozen_string_literal: true

class Assistance < ApplicationRecord
  belongs_to :company
  belongs_to :question
  belongs_to :user

  validates :question, :description, :company, presence: true
end
