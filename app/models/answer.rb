# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :parent_question, class_name: 'Question', foreign_key: :question_id
  has_one :child_question, class_name: 'Question'
  has_one :assistance

  validates :parent_question, presence: true

  def to_s
    "#{id} - #{label}"
  end
end
