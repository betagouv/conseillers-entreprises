class Search < ApplicationRecord
  ## Associations
  #
  belongs_to :user, inverse_of: :searches

  ## Validations
  #
  validates :user, presence: true

  ## Scopes
  #
  scope :recent, (-> { order(created_at: :desc).limit(30) })

  ##
  #
  def summary
    label || query
  end
end
