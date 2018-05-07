# frozen_string_literal: true

class Expert < ApplicationRecord
  include PersonConcern

  belongs_to :institution

  has_many :assistances_experts, dependent: :destroy
  has_many :assistances, through: :assistances_experts
  has_many :expert_territories, dependent: :destroy
  has_many :territories, through: :expert_territories
  has_many :territory_cities, through: :territories

  accepts_nested_attributes_for :assistances_experts, allow_destroy: true
  accepts_nested_attributes_for :expert_territories, allow_destroy: true

  validates :institution, :email, :access_token, presence: true
  validates :access_token, uniqueness: true

  before_validation :generate_access_token!, on: :create

  scope :of_city_code, (lambda do |city_code|
    joins(territories: :territory_cities).where(territories: { territory_cities: { city_code: city_code.to_s } })
  end)
  scope :ordered_by_names, (-> { order(:first_name, :last_name) })

  def generate_access_token!
    self.access_token = SecureRandom.hex(32)

    if Expert.exists?(access_token: access_token)
      generate_access_token!
    end
  end
end
