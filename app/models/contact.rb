# == Schema Information
#
# Table name: contacts
#
#  id           :bigint(8)        not null, primary key
#  email        :string
#  full_name    :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :bigint(8)        not null
#
# Indexes
#
#  index_contacts_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class Contact < ApplicationRecord
  include PersonConcern

  ## Associations
  #
  belongs_to :company, inverse_of: :contacts
  has_many :diagnoses, dependent: :restrict_with_error, foreign_key: 'visitee_id', inverse_of: :visitee
  has_many :needs, through: :diagnoses, inverse_of: :visitee

  ## Validations
  #
  validates :company, presence: true
  validate :at_least_email_or_phone_number

  ##
  #
  def at_least_email_or_phone_number
    if email.blank? && phone_number.blank?
      errors.add(:base, "Contact must have at least email or phone_number")
    end
  end
end
