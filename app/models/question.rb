# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :answers
  belongs_to :answer
  belongs_to :category

  scope :without_anwser_parent, (-> { where(answer: nil) })

  def to_s
    label
  end
end
