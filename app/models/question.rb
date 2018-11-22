# frozen_string_literal: true

class Question < ApplicationRecord
  ## Associations
  #
  belongs_to :category, inverse_of: :questions

  has_many :assistances, dependent: :nullify, inverse_of: :question
  has_many :diagnosed_needs, dependent: :nullify, inverse_of: :question

  ## Validations
  #
  validates :category, presence: true

  ## Through Associations
  #
  # :diagnosed_needs
  has_many :diagnoses, through: :diagnosed_needs, inverse_of: :questions

  ## Scopes
  #
  default_scope { order(:interview_sort_order, :id) }

  ##
  #
  def to_s
    label
  end
end
