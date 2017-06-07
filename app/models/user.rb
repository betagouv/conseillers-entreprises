# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, :institution, :role, :phone_number, presence: true

  after_create :send_admin_mail, unless: :is_approved?

  scope :for_contact_page, (-> { where.not(contact_page_order: nil).order(:contact_page_order) })

  def active_for_authentication?
    super && is_approved?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def send_admin_mail
    AdminMailer.new_user_created_notification(self).deliver
  rescue AdminMailer::RecipientsExpectedError
    Rails.logger.warn 'No recipients present for new User email.'
  end
end
