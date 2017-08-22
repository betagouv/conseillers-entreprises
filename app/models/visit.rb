# frozen_string_literal: true

class Visit < ApplicationRecord
  belongs_to :advisor, class_name: 'User'
  belongs_to :visitee, class_name: 'Contact'
  belongs_to :facility

  has_one :diagnosis
  accepts_nested_attributes_for :visitee

  validates :advisor, :facility, presence: true

  scope :of_advisor, (->(user) { where(advisor: user) })
  scope :of_facility, (->(facility) { where(facility: facility) })
  scope :of_siret, (->(siret) { joins(:facility).where(facilities: { siret: siret }) })
  scope :with_completed_diagnosis, (-> { joins(:diagnosis).merge(Diagnosis.completed) })

  def to_s
    I18n.t('visits.to_s', company_name: company_name)
  end

  def happened_at_localized
    I18n.l happened_at if happened_at
  end

  def company_name
    facility.company.name_short
  end

  def location
    facility.city_code
  end
end
