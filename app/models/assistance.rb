# frozen_string_literal: true

class AssistanceValidator < ActiveModel::Validator
  def validate(assistance)
    assistance.errors.add(:institution, :email_blank) if !assistance.expert && assistance.institution&.email.blank?
  end
end

class Assistance < ApplicationRecord
  AUTHORIZED_COUNTIES = [59, 62].freeze

  enum geographic_scope: %i[region county town]

  belongs_to :question
  belongs_to :institution
  belongs_to :expert

  validates :title, :question, :institution, presence: true
  validates :county, presence: true, if: :county?
  validates :county, inclusion: { in: AUTHORIZED_COUNTIES }, if: :county?
  validates_with AssistanceValidator

  scope :for_maubeuge, (-> { where(for_maubeuge: true) })
  scope :of_location, (lambda do |city_code|
    in_maubeuge = UseCases::LocalizeCityCode.new(city_code).in_maubeuge?
    where(for_maubeuge: in_maubeuge)
  end)
end
