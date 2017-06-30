# frozen_string_literal: true

class Expert < ApplicationRecord
  include PersonConcern

  belongs_to :institution

  has_many :assistances_experts
  has_many :assistances, through: :assistances_experts

  accepts_nested_attributes_for :assistances_experts, allow_destroy: true

  validates :institution, :email, presence: true

  scope :of_location, (lambda do |city_code|
    in_maubeuge = UseCases::LocalizeCityCode.new(city_code).in_maubeuge?
    in_valenciennes_cambrai = UseCases::LocalizeCityCode.new(city_code).in_valenciennes_cambrai?
    in_calais = UseCases::LocalizeCityCode.new(city_code).in_calais?
    in_lens = UseCases::LocalizeCityCode.new(city_code).in_lens?

    if in_maubeuge
      where(on_maubeuge: true)
    elsif in_valenciennes_cambrai
      where(on_valenciennes_cambrai: true)
    elsif in_calais
      where(on_calais: true)
    elsif in_lens
      where(on_lens: true)
    else
      none
    end
  end)
end
