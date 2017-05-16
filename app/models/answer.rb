# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :parent_question, class_name: 'Question', foreign_key: :question_id
  has_one :child_question, class_name: 'Question'

  validates :parent_question, presence: true
end
