# == Schema Information
#
# Table name: experts
#
#  id             :bigint(8)        not null, primary key
#  access_token   :string
#  email          :string
#  full_name      :string
#  is_global_zone :boolean          default(FALSE)
#  phone_number   :string
#  role           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  antenne_id     :bigint(8)        not null
#
# Indexes
#
#  index_experts_on_access_token  (access_token)
#  index_experts_on_antenne_id    (antenne_id)
#  index_experts_on_email         (email)
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

  has_many :experts_skills, dependent: :destroy
  has_many :skills, through: :experts_skills, dependent: :destroy, inverse_of: :experts # TODO should be direct once we remove the ExpertSkill model and use a HABTM
  has_many :received_matches, class_name: 'Match', inverse_of: :expert

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
  has_many :received_needs, through: :received_matches, source: :need, inverse_of: :experts
  has_many :received_diagnoses, through: :received_matches, source: :diagnosis, inverse_of: :experts
  has_many :feedbacks, through: :received_matches, inverse_of: :expert

  ##
  #
  accepts_nested_attributes_for :experts_skills, allow_destroy: true
  accepts_nested_attributes_for :users, allow_destroy: true

  ## Scopes
  #
  scope :support_experts, -> do
    joins(:skills)
      .merge(Skill.support_skills)
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
    joins(:antenne, :antenne_institution)
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

  scope :without_users, -> { left_outer_joins(:users).where(users: { id: nil }) }

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
    "#{full_name} (#{full_role})"
  end

  def full_role
    "#{role} - #{antenne.name}"
  end

  ##
  #
  def create_matching_user!
    if !users.empty?
      return
    end

    params = {
      experts: [self],
      email: email,
      full_name: full_name,
      phone_number: phone_number,
      antenne: antenne,
      role: role
    }
    params[:password] = SecureRandom.base64(8)
    params[:is_approved] = true

    user = User.new(params)
    user.skip_confirmation_notification!
    user.save!
  end
end
