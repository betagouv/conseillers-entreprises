# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :answers
  has_many :assistances
  belongs_to :answer
  belongs_to :category

  scope :without_answer_parent, (-> { where(answer: nil) })

  def to_s
    label
  end
end
