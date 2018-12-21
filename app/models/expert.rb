class Expert < ApplicationRecord
  include PersonConcern

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :direct_experts
  include ManyCommunes

  belongs_to :antenne, counter_cache: true, inverse_of: :experts

  has_and_belongs_to_many :users, inverse_of: :experts

  has_many :assistances_experts, dependent: :destroy
  has_many :assistances, through: :assistances_experts, dependent: :destroy, inverse_of: :experts # TODO should be direct once we remove the AssistanceExpert model and use a HABTM
  has_many :received_matches, through: :assistances_experts, source: :matches, inverse_of: :expert # TODO should be direct once we remove the AssistanceExpert model and use a HABTM

  ## Validations
  #
  validates :antenne, :email, :access_token, presence: true
  validates :access_token, uniqueness: true

  before_validation :generate_access_token!, on: :create

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :direct_experts

  # :antenne
  has_one :antenne_institution, through: :antenne, source: :institution, inverse_of: :experts
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :antenne_experts
  has_many :antenne_territories, -> { distinct }, through: :antenne, source: :territories, inverse_of: :antenne_experts

  # :matches
  has_many :received_diagnosed_needs, through: :received_matches, source: :diagnosed_need, inverse_of: :experts
  has_many :received_diagnoses, through: :received_matches, source: :diagnosis, inverse_of: :experts
  has_many :feedbacks, through: :received_matches, inverse_of: :expert

  ##
  #
  accepts_nested_attributes_for :assistances_experts, allow_destroy: true
  accepts_nested_attributes_for :users, allow_destroy: true

  ## Scopes
  #
  scope :of_naf_code, -> (naf_code) do
    joins(:antenne_institution).merge(Institution.of_naf_code(naf_code))
  end

  scope :ordered_by_institution, -> do
    joins(:antenne, :antenne_institution)
      .select('experts.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :with_custom_communes, -> do
    # The naive “joins(:communes).distinct” is way more complex.
    where('EXISTS (SELECT * FROM communes_experts WHERE communes_experts.expert_id = experts.id)')
  end
  scope :without_custom_communes, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

  ##
  #
  def generate_access_token!
    self.access_token = SecureRandom.hex(32)

    if Expert.exists?(access_token: access_token)
      generate_access_token!
    end
  end

  ## Description
  #
  def is_oneself?
    self.users.size == 1 && self.users.first.experts == [self]
  end

  def custom_communes?
    communes.any?
  end

  def full_name_with_role
    "#{full_name} (#{role}, #{antenne.name})"
  end
end
