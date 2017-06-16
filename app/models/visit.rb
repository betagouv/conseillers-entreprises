# frozen_string_literal: true

class Visit < ApplicationRecord
  belongs_to :advisor, class_name: 'User'
  belongs_to :visitee, class_name: 'User'
  accepts_nested_attributes_for :visitee

  validates :happened_at, :siret, :advisor, presence: true

  scope :of_advisor, (->(user) { where(advisor: user) })

  def to_s
    "Visite du #{I18n.l(happened_at)} SIRET #{siret}"
  end
end
