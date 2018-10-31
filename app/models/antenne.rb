class Antenne < ApplicationRecord
  ## Relations and Validations
  #
  belongs_to :institution
  has_and_belongs_to_many :communes, join_table: :intervention_zones
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
end
