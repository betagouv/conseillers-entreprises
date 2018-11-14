# frozen_string_literal: true

class Assistance < ApplicationRecord
  attr_accessor :filtered_assistances_experts

  belongs_to :question
  has_one :category, through: :question

  has_many :assistances_experts, dependent: :destroy
  has_many :experts, through: :assistances_experts

  accepts_nested_attributes_for :assistances_experts, allow_destroy: true

  validates :title, :question, presence: true

  scope :of_diagnosis, (lambda do |diagnosis|
    joins(question: :diagnosed_needs).merge(DiagnosedNeed.of_diagnosis(diagnosis))
  end)
end
