# == Schema Information
#
# Table name: visits
#
#  id          :bigint(8)        not null, primary key
#  happened_on :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  advisor_id  :bigint(8)
#  facility_id :bigint(8)
#  visitee_id  :bigint(8)
#
# Indexes
#
#  index_visits_on_advisor_id   (advisor_id)
#  index_visits_on_facility_id  (facility_id)
#  index_visits_on_visitee_id   (visitee_id)
#
# Foreign Keys
#
#  fk_rails_...  (advisor_id => users.id)
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (visitee_id => contacts.id)
#

class Visit < ApplicationRecord
  # TODO merge with the Diagnosis model
  belongs_to :advisor, class_name: 'User'
  belongs_to :visitee, class_name: 'Contact', optional: true
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
