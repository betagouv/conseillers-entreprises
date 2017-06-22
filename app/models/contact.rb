# frozen_string_literal: true

class ContactValidator < ActiveModel::Validator
  def validate(contact)
    contact.errors.add(:email, :blank) if contact.email.blank? && contact.phone_number.blank?
  end
end

class Contact < ApplicationRecord
  include PersonConcern

  belongs_to :company

  validates :company, presence: true
  validates_with ContactValidator

  def full_name=(full_name)
    return unless full_name
    split_full_name = full_name.split(' ')
    return nil if split_full_name.count.zero?
    case split_full_name.count
    when 1
      self.last_name = split_full_name[0]
    else
      self.first_name = split_full_name[0]
      self.last_name = split_full_name[1..-1].join(' ')
    end
  end
end
