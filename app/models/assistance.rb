# frozen_string_literal: true

class Assistance < ApplicationRecord
  AUTHORIZED_COUNTIES = [59, 62].freeze

  enum geographic_scope: %i[region county town]

  belongs_to :question
  belongs_to :institution

  has_many :assistances_experts
  has_many :experts, through: :assistances_experts

  accepts_nested_attributes_for :assistances_experts, allow_destroy: true

  validates :title, :question, :institution, presence: true
  validates :county, presence: true, if: :county?
  validates :county, inclusion: { in: AUTHORIZED_COUNTIES }, if: :county?

  scope :of_location, (lambda do |city_code|
    in_maubeuge = UseCases::LocalizeCityCode.new(city_code).in_maubeuge?
    in_valenciennes_cambrai = UseCases::LocalizeCityCode.new(city_code).in_valenciennes_cambrai?
    in_calais = UseCases::LocalizeCityCode.new(city_code).in_calais?
    in_lens = UseCases::LocalizeCityCode.new(city_code).in_lens?

    if in_maubeuge
      where(experts: { on_maubeuge: true }).joins(:experts)
    elsif in_valenciennes_cambrai
      where(experts: { on_valenciennes_cambrai: true }).joins(:experts)
    elsif in_calais
      where(experts: { on_calais: true }).joins(:experts)
    elsif in_lens
      where(experts: { on_lens: true }).joins(:experts)
    else
      none
    end
  end)
end
