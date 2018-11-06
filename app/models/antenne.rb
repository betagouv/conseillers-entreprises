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

  ## Temporary: constructors from Institution, Territory, Expert
  #
  class << self
    def default_institution
      Institution.find_by(name: '!Institution temporaire')
    end

    def create_from_territory!(territory)
      a = Antenne.create!(
        name: territory.name,
        institution: default_institution,
        experts: territory.experts,
        communes: territory.communes,
        users: territory.experts.flat_map(&:users)
      )

      territory.update(name: '(antenne créée) ' + territory.name)

      a
    end

    def create_from_institution!(institution)
      # Make sure all experts have the same territories
      if institution.experts.flat_map(&:territories).uniq.length > 1
        raise 'All experts from the institution must have the same territories'
      end

      a = Antenne.create!(
        name: institution.name,
        institution: institution,
        experts: institution.experts,
        communes: institution.experts.first.territories.flat_map(&:communes).uniq,
        users: institution.experts.flat_map(&:users)
      )

      institution.update(name: '(antenne créée) ' + institution.name)

      a
    end

    def create_from_expert!(expert)
      a = Antenne.create!(
        name: expert.full_name,
        institution: expert.institution,
        experts: [expert],
        communes: expert.territories.flat_map(&:communes).uniq,
        users: expert.users
      )

      a
    end
  end
end
