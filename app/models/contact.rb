# == Schema Information
#
# Table name: contacts
#
#  id           :bigint(8)        not null, primary key
#  email        :string
#  full_name    :string           not null
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_contacts_on_email  (email) UNIQUE WHERE ((email IS NOT NULL) AND ((email)::text <> ''::text))
#

class Contact < ApplicationRecord
  include PersonConcern

  ## Associations
  #
  has_many :diagnoses, dependent: :restrict_with_error, foreign_key: 'visitee_id', inverse_of: :visitee
  has_many :needs, through: :diagnoses, inverse_of: :visitee
  has_many :companies, -> { distinct }, through: :diagnoses

  ## Validations
  #
  validate :at_least_email_or_phone_number
  validates :email, uniqueness: { allow_blank: true }

  ##
  #
  def at_least_email_or_phone_number
    if email.blank? && phone_number.blank?
      errors.add(:base, "Contact must have at least email or phone_number")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "full_name", "id", "id_value", "phone_number", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["companies", "diagnoses", "needs"]
  end
end
