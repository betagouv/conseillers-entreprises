class Antenne < ApplicationRecord
  ## Relations and Validations
  #
  include ManyCommunes
  belongs_to :institution, counter_cache: true
  has_many :experts
  has_many :users

  validates :name, presence: true, uniqueness: true
  validates :institution, presence: true

  ## Matches, Sent and Received
  #
  def sent_matches
    Match.sent_by(users)
  end

  def received_matches
    Match.of_relay_or_expert(experts)
  end

  ##
  #
  def to_s
    name
  end
end
