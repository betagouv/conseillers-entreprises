# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :answers

  def to_s
    label
  end
end
