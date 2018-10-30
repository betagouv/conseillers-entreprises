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
      if institution.experts.map(&:territories).uniq.length > 1
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

      expert.update(full_name: '(antenne créée) ' + expert.full_name)

      a
    end
  end
end
