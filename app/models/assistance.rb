# frozen_string_literal: true

class Assistance < ApplicationRecord
  ## Associations
  #
  belongs_to :question, inverse_of: :assistances

  has_many :assistances_experts, dependent: :destroy
  has_many :experts, through: :assistances_experts, inverse_of: :assistances # TODO should be direct once we remove the AssistanceExpert model and use a HABTM

  ## Validations
  #
  validates :title, :question, presence: true

  ## Through Associations
  #
  has_one :category, through: :question, inverse_of: :assistances

  ## Scopes
  #
  scope :of_diagnosis, (lambda do |diagnosis|
    joins(question: :diagnosed_needs).merge(DiagnosedNeed.of_diagnosis(diagnosis))
  end)

  ##
  #
  attr_accessor :filtered_assistances_experts

  ##
  #
  def to_s
    title
  end
end
