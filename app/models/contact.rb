# frozen_string_literal: true

class Contact < ApplicationRecord
  include PersonConcern

  ## Associations
  #
  belongs_to :company, inverse_of: :contacts
  has_many :visits, foreign_key: 'visitee_id', dependent: :restrict_with_error, inverse_of: :visitee

  ## Validations
  #
  validates :company, presence: true
  validates_with ContactValidator

  ##
  #
  def can_be_viewed_by?(role)
    visits.any? { |visit| visit.can_be_viewed_by?(role) }
  end
end
