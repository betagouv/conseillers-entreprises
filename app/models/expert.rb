# frozen_string_literal: true

class Expert < ApplicationRecord
  include PersonConcern

  ## Relations and Validations
  #
  belongs_to :antenne, counter_cache: true
  has_one :institution, through: :antenne

  has_and_belongs_to_many :users
  has_many :assistances_experts, dependent: :destroy
  has_many :assistances, through: :assistances_experts, dependent: :destroy
  has_many :matches, -> { ordered_by_status }, through: :assistances_experts
  has_many :expert_territories, dependent: :destroy
  has_many :territories, through: :expert_territories
  has_and_belongs_to_many :communes

  validates :antenne, :email, :access_token, presence: true
  validates :access_token, uniqueness: true

  before_validation :generate_access_token!, on: :create

  ##
  #
  accepts_nested_attributes_for :assistances_experts, allow_destroy: true
  accepts_nested_attributes_for :expert_territories, allow_destroy: true
  accepts_nested_attributes_for :users, allow_destroy: true

  ## Scopes
  #
  scope :of_naf_code, -> (naf_code) do
    joins(:institution).merge(Institution.of_naf_code(naf_code))
  end

  scope :ordered_by_names, (-> { order(:full_name) })

  scope :with_custom_zone, -> { joins(:communes).distinct }
  scope :without_custom_zone, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

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

  def full_name_with_role
    "#{full_name} (#{role}, #{antenne.name})"
  end
end
