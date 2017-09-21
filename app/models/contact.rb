# frozen_string_literal: true

class ContactValidator < ActiveModel::Validator
  def validate(contact)
    contact.errors.add(:email, :blank) if contact.email.blank? && contact.phone_number.blank?
  end
end

class Contact < ApplicationRecord
  include PersonConcern

  belongs_to :company
  has_many :visits, foreign_key: 'visitee_id', dependent: :restrict_with_error

  validates :company, presence: true
  validates_with ContactValidator

  def can_be_viewed_by?(user)
    visits.any? { |visit| visit.can_be_viewed_by?(user) }
  end

  def full_name=(full_name)
    return unless full_name
    split_full_name = full_name.split(' ')
    return if split_full_name.count.zero?
    case split_full_name.count
    when 1
      self.last_name = split_full_name[0]
    else
      self.first_name = split_full_name[0]
      self.last_name = split_full_name[1..-1].join(' ')
    end
  end
end
