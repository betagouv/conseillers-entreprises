# frozen_string_literal: true

class Expert < ApplicationRecord
  include PersonConcern

  belongs_to :institution

  has_many :assistances_experts, dependent: :destroy
  has_many :assistances, through: :assistances_experts

  accepts_nested_attributes_for :assistances_experts, allow_destroy: true

  validates :institution, :email, presence: true
  validates :access_token, uniqueness: true

  before_validation :generate_access_token!, on: :create

  def generate_access_token!
    self.access_token = SecureRandom.hex(32)
    generate_access_token! if Expert.exists?(access_token: access_token)
  end
end
