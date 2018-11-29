class Antenne < ApplicationRecord
  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :antennes
  include ManyCommunes

  belongs_to :institution, counter_cache: true, inverse_of: :antennes

  has_many :experts, inverse_of: :antenne
  has_many :advisors, class_name: 'User', inverse_of: :antenne

  ## Validations
  #
  validates :name, presence: true, uniqueness: true
  validates :institution, presence: true

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :antennes

  # :advisors
  has_many :sent_diagnoses, through: :advisors, inverse_of: :advisor_antenne
  has_many :sent_diagnosed_needs, through: :advisors, inverse_of: :advisor_antenne
  has_many :sent_matches, through: :advisors, inverse_of: :advisor_antenne

  # :experts
  has_many :received_matches, through: :experts, inverse_of: :expert_antenne
  has_many :received_diagnosed_needs, through: :experts, inverse_of: :experts_antennes
  has_many :received_diagnoses, through: :experts, inverse_of: :expert_antenne

  ##
  #
  scope :without_communes, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

  ##
  #
  def to_s
    name
  end
end
