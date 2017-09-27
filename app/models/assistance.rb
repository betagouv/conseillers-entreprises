# frozen_string_literal: true

class Assistance < ApplicationRecord
  AUTHORIZED_COUNTIES = [59, 62].freeze

  enum geographic_scope: %i[region county town]

  belongs_to :question
  belongs_to :institution

  has_many :assistances_experts, dependent: :destroy
  has_many :experts, through: :assistances_experts

  accepts_nested_attributes_for :assistances_experts, allow_destroy: true

  validates :title, :question, :institution, presence: true
  validates :county, presence: true, if: :county?
  validates :county, inclusion: { in: AUTHORIZED_COUNTIES }, if: :county?

  scope :of_diagnosis, (lambda do |diagnosis|
    joins(question: :diagnosed_needs).merge(DiagnosedNeed.of_diagnosis(diagnosis))
  end)
end
