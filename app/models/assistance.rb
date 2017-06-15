# frozen_string_literal: true

class Assistance < ApplicationRecord
  belongs_to :question
  belongs_to :company
  belongs_to :user

  validates :title, :question, :company, presence: true
end
