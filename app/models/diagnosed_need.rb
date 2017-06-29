# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  has_one :visit, through: :diagnosis
  has_one :facility, through: :visit

  has_many :assistances,
           (lambda do |diagnosed_need|
             city_code = diagnosed_need.diagnosis.visit.facility.city_code
             in_maubeuge = UseCases::LocalizeCityCode.new(city_code).in_maubeuge?
             where(assistances: { for_maubeuge: in_maubeuge })
           end),
           class_name: 'Assistance',
           through: :question

  validates :diagnosis, presence: true
end
