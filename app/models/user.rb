# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable

  validates :last_name, :role, :email, presence: true

  # Inspired by Devise validatable module
  validates :email, uniqueness: true, format: { with: Devise.email_regexp }, allow_blank: true, if: :will_save_change_to_email?
  validates :password, length: { within: Devise.password_length }, allow_blank: true, unless: :added_by_advisor?
  validates :password, presence: true, confirmation: true, if: :must_validate_password?

  after_create :send_admin_mail, if: :must_send_admin_mail?

  scope :for_contact_page, (-> { where.not(contact_page_order: nil).order(:contact_page_order) })

  def active_for_authentication?
    super && is_approved?
  end

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

  def full_name
    "#{first_name} #{last_name}"
  end

  protected

  def must_validate_password?
    password_required? && !added_by_advisor?
  end

  def must_send_admin_mail?
    !is_approved? && !added_by_advisor?
  end

  def send_admin_mail
    AdminMailer.new_user_created_notification(self).deliver
  rescue AdminMailer::RecipientsExpectedError
    Rails.logger.warn 'No recipients present for new User email.'
  end

  # Inspired by Devise validatable module
  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
