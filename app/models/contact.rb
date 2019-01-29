# == Schema Information
#
# Table name: contacts
#
#  id           :bigint(8)        not null, primary key
#  email        :string
#  full_name    :string
#  phone_number :string
#  role         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :bigint(8)
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

  ## Validations
  #
  validates :company, presence: true
  validates_with ContactValidator

  ##
  #
  def can_be_viewed_by?(role)
    diagnoses.any? { |diagnosis| diagnosis.can_be_viewed_by?(role) }
  end
end
