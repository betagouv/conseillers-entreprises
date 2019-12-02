# == Schema Information
#
# Table name: experts
#
#  id              :bigint(8)        not null, primary key
#  access_token    :string
#  email           :string
#  full_name       :string
#  is_global_zone  :boolean          default(FALSE)
#  phone_number    :string           not null
#  reminders_notes :text
#  role            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  antenne_id      :bigint(8)        not null
#
# Indexes
#
#  index_experts_on_access_token  (access_token)
#  index_experts_on_antenne_id    (antenne_id)
#  index_experts_on_email         (email)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#

class Expert < ApplicationRecord
  include PersonConcern
  include InvolvementConcern

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :direct_experts
  include ManyCommunes

  belongs_to :antenne, counter_cache: true, inverse_of: :experts

  has_and_belongs_to_many :users, inverse_of: :experts

  has_many :experts_subjects, dependent: :destroy, inverse_of: :expert
  has_many :received_matches, class_name: 'Match', inverse_of: :expert

  has_many :feedbacks, dependent: :destroy, inverse_of: :expert

  ## Validations
  #
  validates :antenne, :email, :phone_number, :access_token, presence: true
  validates :users, presence: true
  validates :access_token, uniqueness: true

  before_validation :generate_access_token!, on: :create

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :direct_experts

  # :antenne
  has_one :institution, through: :antenne, source: :institution, inverse_of: :experts
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :antenne_experts
  has_many :antenne_territories, -> { distinct }, through: :antenne, source: :territories, inverse_of: :antenne_experts

  # :matches
  has_many :received_needs, through: :received_matches, source: :need, inverse_of: :experts
  has_many :received_diagnoses, through: :received_matches, source: :diagnosis, inverse_of: :experts

  # :subjects
  has_many :subjects, through: :experts_subjects, inverse_of: :experts
  ##
  #
  accepts_nested_attributes_for :users, allow_destroy: true
  accepts_nested_attributes_for :experts_subjects, allow_destroy: true

  ## Scopes
  #
  scope :support_experts, -> do
    joins(:subjects)
      .where({ subjects: { is_support: true } })
  end

  scope :with_active_matches, -> do
    joins(:received_matches)
      .merge(Match.active)
      .distinct
  end

  scope :with_active_abandoned_matches, -> do
    joins(:received_matches)
      .merge(Match.active_abandoned)
      .distinct
  end

  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('experts.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :with_custom_communes, -> do
    # The naive “joins(:communes).distinct” is way more complex.
    where('EXISTS (SELECT * FROM communes_experts WHERE communes_experts.expert_id = experts.id)')
  end
  scope :without_custom_communes, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

  scope :with_global_zone, -> do
    where(is_global_zone: true)
  end

  scope :omnisearch, -> (query) do
    joins(:antenne)
      .where('experts.full_name ILIKE ?', "%#{query}%")
      .or(Expert.joins(:antenne).where('antennes.name ILIKE ?', "%#{query}%"))
  end

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
    "#{full_name} #{full_role}"
  end

  def full_role
    "#{role} - #{antenne.name}"
  end

  ##
  #
  def can_be_viewed_by?(role)
    if role.is_a?(User) && role.is_admin
      return true
    end

    if role.is_a?(Expert) && self == role
      return true
    end

    false
  end

  def can_be_modified_by?(role)
    can_be_viewed_by?(role)
  end
end
