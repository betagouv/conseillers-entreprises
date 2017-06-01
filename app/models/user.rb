# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  scope :for_contact_page, (-> { where.not(contact_page_order: nil).order(:contact_page_order) })

  def active_for_authentication?
    super && is_approved?
  end

  def inactive_message
    if !is_approved?
      :not_approved
    else
      super
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
