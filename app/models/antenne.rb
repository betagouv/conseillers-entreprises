class Antenne < ApplicationRecord
  ## Relations and Validations
  #
  belongs_to :institution, counter_cache: true
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

  ##
  #
  def to_s
    name
  end

  def insee_codes
    communes.pluck(:insee_code)
  end

  def insee_codes=(codes_raw)
    wanted_codes = codes_raw.split(/[,\s]/).delete_if(&:empty?)
    if wanted_codes.any? { |code| code !~ Commune::INSEE_CODE_FORMAT }
      raise 'Invalid city codes'
    end

    wanted_codes.each do |code|
      Commune.find_or_create_by(insee_code: code)
    end

    self.communes = Commune.where(insee_code: wanted_codes)
  end
end
