# frozen_string_literal: true

class User < ApplicationRecord
  WHITELISTED_DOMAINS = %w[beta.gouv.fr direccte.gouv.fr pole-emploi.fr pole-emploi.net cma-hautsdefrance.fr urssaf.fr].freeze

  include PersonConcern

  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable

  has_many :relays
  has_many :territories, through: :relays
  has_many :visits, foreign_key: 'advisor_id'
  has_many :searches

  validates :first_name, :email, :phone_number, presence: true

  # Inspired by Devise validatable module
  validates :email,
            uniqueness: true,
            format: { with: Devise.email_regexp },
            allow_blank: true,
            if: :will_save_change_to_email?

  validates :password, length: { within: Devise.password_length }, allow_blank: true
  validates :password, presence: true, confirmation: true, if: :password_required?

  before_create :auto_approve_if_whitelisted_domain

  scope :with_contact_page_order, (-> { where.not(contact_page_order: nil).order(:contact_page_order) })
  scope :contact_relays, (lambda do
    where(contact_page_order: nil)
        .joins(:relays)
        .distinct
        .order(:first_name, :last_name)
  end)
  scope :not_admin, (-> { where(is_admin: false) })
  scope :ordered_by_names, (-> { order(:first_name, :last_name) })

  scope :active_searchers, (lambda do |date|
    joins(:searches)
        .merge(Search.where(created_at: date))
        .uniq
  end)
  
  scope :active_diagnosers, (lambda do |date, minimum_step|
    joins(visits: :diagnosis)
        .merge(Diagnosis.where(created_at: date)
                   .after_step(minimum_step))
        .uniq
  end)

  scope :active_answered, (lambda do |date, status|
    joins(visits: [diagnosis: [diagnosed_needs: :selected_assistance_experts]])
        .merge(SelectedAssistanceExpert
                   .where(taken_care_of_at: date)
                   .with_status(status))
        .uniq
  end)

  def active_for_authentication?
    super && is_approved?
  end

  def full_name_with_role
    "#{first_name} #{last_name}, #{role}, #{institution}"
  end

  def auto_approve_if_whitelisted_domain
    email_domain = email.split("@").last
    if email_domain.in?(WHITELISTED_DOMAINS)
      self.is_approved = true
    end
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
