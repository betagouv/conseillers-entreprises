# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable

  validates :first_name, :last_name, :role, :email, :phone_number, presence: true

  # Inspired by Devise validatable module
  validates :email,
            uniqueness: true,
            format: { with: Devise.email_regexp },
            allow_blank: true,
            if: :will_save_change_to_email?

  validates :password, length: { within: Devise.password_length }, allow_blank: true
  validates :password, presence: true, confirmation: true, if: :password_required?

  scope :for_contact_page, (-> { where.not(contact_page_order: nil).order(:contact_page_order) })
  scope :not_admin, (-> { where(is_admin: false) })

  def active_for_authentication?
    super && is_approved?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_with_role
    "#{first_name} #{last_name}, #{role}, #{institution}"
  end

  protected

  # Inspired by Devise validatable module
  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
