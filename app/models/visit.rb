# frozen_string_literal: true

class Visit < ApplicationRecord
  belongs_to :advisor, class_name: 'User'
  belongs_to :visitee, class_name: 'Contact'
  belongs_to :facility

  has_one :diagnosis
  accepts_nested_attributes_for :visitee

  validates :advisor, :facility, presence: true

  scope :of_siret, (->(siret) { joins(:facility).where(facilities: { siret: siret }) })

  def to_s
    "#{company_name} (#{happened_on_localized})"
  end

  def happened_on_localized
    if happened_on
      I18n.l happened_on
    end
  end

  def company_name
    facility.company.name_short
  end

  def can_be_viewed_by?(user)
    advisor == user
  end
end
