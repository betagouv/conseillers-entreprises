# frozen_string_literal: true

class Contact < ApplicationRecord
  include PersonConcern

  belongs_to :company
  has_many :visits, foreign_key: 'visitee_id', dependent: :restrict_with_error

  validates :company, presence: true
  validates_with ContactValidator

  scope :ordered_by_names, (-> { order(:full_name) })

  def can_be_viewed_by?(role)
    visits.any? { |visit| visit.can_be_viewed_by?(role) }
  end
end
