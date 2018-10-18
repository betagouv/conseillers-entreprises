# frozen_string_literal: true

class User < ApplicationRecord
  WHITELISTED_DOMAINS = %w[beta.gouv.fr direccte.gouv.fr pole-emploi.fr pole-emploi.net cma-hautsdefrance.fr].freeze

  include PersonConcern

  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable, :async

  has_many :relays
  has_many :territories, through: :relays
  has_many :visits, foreign_key: 'advisor_id'
  has_many :diagnoses, through: :visits
  has_many :searches, dependent: :destroy
  has_and_belongs_to_many :experts

  validates :full_name, :email, :phone_number, presence: true

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
    not_admin
      .joins(:relays)
      .includes(relays: :territory)
      .order('territories.name', :contact_page_order, :full_name)
      .distinct
  end)
  scope :not_admin, (-> { where(is_admin: false) })
  scope :ordered_by_names, (-> { order(:full_name) })

  scope :active_searchers, (lambda do |date|
    joins(:searches)
        .merge(Search.where(created_at: date))
        .uniq
  end)

  scope :active_diagnosers, (lambda do |date, minimum_step|
    joins(visits: :diagnosis)
        .merge(Diagnosis.only_active
                   .where(created_at: date)
                   .after_step(minimum_step))
        .uniq
  end)

  scope :active_answered, (lambda do |date, status|
    joins(visits: [diagnosis: [diagnosed_needs: :matches]])
        .merge(Match
                   .where(taken_care_of_at: date)
                   .with_status(status))
        .uniq
  end)

  def active_for_authentication?
    super && is_approved?
  end

  def full_name_with_role
    "#{full_name}, #{role}, #{institution}"
  end

  def auto_approve_if_whitelisted_domain
    email_domain = email.split("@").last
    if email_domain.in?(WHITELISTED_DOMAINS)
      self.is_approved = true
    end
  end

  def corresponding_experts
    Expert.where(email: self.email)
  end

  def autolink_experts!
    if self.experts.empty?
      corresponding = self.corresponding_experts
      if corresponding.present?
        self.experts = corresponding
        self.save!
      end
    end
  end

  def is_oneself?
    self.experts.length == 1 && self.experts.first.users == [self]
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
