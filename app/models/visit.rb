class Visit < ApplicationRecord
  # TODO merge with the Diagnosis model
  belongs_to :advisor, class_name: 'User'
  belongs_to :visitee, class_name: 'Contact', required: false
  belongs_to :facility

  has_one :company, through: :facility

  has_one :diagnosis, dependent: :destroy
  accepts_nested_attributes_for :visitee

  validates :advisor, :facility, presence: true

  def to_s
    "#{company_name} (#{I18n.l display_date})"
  end

  def display_date
    happened_on || created_at.to_date
  end

  def company_name
    facility.company.name
  end

  def company_description
    facility.to_s
  end

  def can_be_viewed_by?(role)
    role.present? && advisor == role
  end
end
