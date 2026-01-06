# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  absence_end_at         :datetime
#  absence_start_at       :datetime
#  app_info               :jsonb
#  cgu_accepted_at        :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  demo_invited_at        :datetime
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  full_name              :string
#  imported_at            :datetime
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  job                    :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  phone_number           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)        not null
#  inviter_id             :bigint(8)
#
# Indexes
#
#  index_users_on_antenne_id            (antenne_id)
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE WHERE ((email)::text <> NULL::text)
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_inviter_id            (inviter_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (inviter_id => users.id)
#

class User < ApplicationRecord
  ##
  #
  include PgSearch::Model
  include PersonConcern
  include InvolvementConcern
  include SoftDeletable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :async,
         :validatable,
         :invitable, invited_by_class_name: 'User', validate_on_invite: true

  attr_accessor :cgu_accepted, :specifics_territories, :create_expert

  store_accessor :app_info, ['bascule_seen']

  after_create_commit :create_single_user_experts, if: -> { create_expert.to_b }
  before_validation :fill_absence_start_at, if: -> { absence_end_at.present? && absence_start_at.nil? }
  after_update :add_shared_satisfactions, if: -> { is_manager? }

  pg_search_scope :omnisearch,
    against: [:full_name, :email, :job],
    associated_against: {
      antenne: [:name]
    },
    using: { tsearch: { prefix: true } },
    ignoring: :accents

  ## Associations
  #
  belongs_to :antenne, inverse_of: :advisors
  has_one :profil_picture

  has_and_belongs_to_many :experts, -> { not_deleted }, inverse_of: :users
  has_and_belongs_to_many :experts_with_subjects, -> { not_deleted.with_subjects }, class_name: "Expert", inverse_of: :users
  has_many :shared_satisfactions, inverse_of: :user
  has_many :shared_company_satisfactions, through: :shared_satisfactions, source: :company_satisfaction
  has_many :needs_with_shared_satisfaction, through: :shared_company_satisfactions, source: :need

  has_many :sent_diagnoses, class_name: 'Diagnosis', foreign_key: 'advisor_id', inverse_of: :advisor
  has_many :feedbacks, inverse_of: :user
  belongs_to :inviter, class_name: 'User', inverse_of: :invitees, optional: true
  has_many :invitees, class_name: 'User', foreign_key: 'inviter_id', inverse_of: :inviter, counter_cache: :invitations_count
  has_many_attached :csv_exports

  # :rights / roles
  has_many :user_rights, inverse_of: :user, dependent: :destroy
  has_many :user_rights_manager, ->{ category_manager }, class_name: 'UserRight', inverse_of: :user
  has_many :user_rights_admin, ->{ category_admin }, class_name: 'UserRight', inverse_of: :user
  has_many :user_rights_for_admin, ->{ for_admin }, class_name: 'UserRight', inverse_of: :user
  has_many :user_rights_cooperation_manager, ->{ category_cooperation_manager }, class_name: 'UserRight', inverse_of: :user
  has_many :user_rights_territorial_referent, ->{ category_territorial_referent }, class_name: 'UserRight', inverse_of: :user
  has_many :managed_antennes, ->{ distinct }, through: :user_rights_manager, source: :antenne, inverse_of: :managers
  has_many :managed_cooperations, ->{ distinct }, through: :user_rights_cooperation_manager, source: :cooperation, inverse_of: :managers
  # Utiles pour active_admin
  accepts_nested_attributes_for :user_rights, allow_destroy: true
  accepts_nested_attributes_for :user_rights_for_admin, allow_destroy: true
  accepts_nested_attributes_for :user_rights_territorial_referent, allow_destroy: true
  accepts_nested_attributes_for :user_rights_manager, allow_destroy: true
  accepts_nested_attributes_for :user_rights_cooperation_manager, allow_destroy: true

  ## Validations
  #
  validates :full_name, presence: true, unless: :deleted?
  validates :job, presence: true
  validate :password_complexity
  validates :user_rights_cooperation_manager, length: { maximum: 1, too_long: I18n.t('errors.only_one_cooperation') }
  validates_associated :experts, on: :import

  ## "Through" Associations
  #
  # :antenne
  has_one :institution, through: :antenne, source: :institution, inverse_of: :advisors

  # :sent_diagnoses
  has_many :sent_needs, through: :sent_diagnoses, source: :needs, inverse_of: :advisor
  has_many :sent_matches, through: :sent_diagnoses, source: :matches, inverse_of: :advisor

  # :experts
  has_many :received_matches, through: :experts, source: :received_matches, inverse_of: :contacted_users
  has_many :activity_matches, through: :experts, source: :activity_matches, inverse_of: :contacted_users
  has_many :received_needs, through: :experts, source: :received_needs, inverse_of: :contacted_users
  has_many :received_diagnoses, through: :experts, source: :received_diagnoses, inverse_of: :contacted_users
  has_many :themes, through: :experts, inverse_of: :advisors
  has_many :subjects, through: :experts, inverse_of: :advisors

  ## Scopes
  #
  scope :admin, -> { not_deleted.joins(:user_rights).merge(UserRight.category_admin) }
  scope :managers, -> { not_deleted.joins(:user_rights).merge(UserRight.category_manager).distinct }
  scope :cooperation_managers, -> { not_deleted.joins(:user_rights).merge(UserRight.category_cooperation_manager).distinct }
  scope :national_referent, -> { not_deleted.joins(:user_rights).merge(UserRight.category_national_referent).distinct }
  scope :cooperations_referent, -> { not_deleted.joins(:user_rights).merge(UserRight.category_cooperations_referent).distinct }

  scope :not_invited, -> { not_deleted.where(invitation_sent_at: nil) }
  scope :managers_not_invited, -> { not_deleted.managers.where(invitation_sent_at: nil) }
  # :invitation_not_accepted and :invitation_accepted are declared in devise_invitable/model.rb
  scope :active_invitation_not_accepted, -> { invitation_not_accepted.active }
  scope :old_active_invitation_not_accepted, -> do
    active_invitation_not_accepted
      .where(invitation_sent_at: ..6.months.ago)
  end
  scope :recent_active_invitation_not_accepted, -> do
    active_invitation_not_accepted
      .where(invitation_sent_at: 6.months.ago..)
  end

  scope :with_activity, -> (date_range = Match::DEFAULT_ACTIVITY_PERIOD) do
    where(id: User.joins(:experts).merge(Expert.with_activity(date_range)))
      .or(where(id: Feedback.where(updated_at: date_range).select(:user_id)))
      .or(where(id: managers))
  end
  scope :without_activity, -> (date_range = Match::DEFAULT_ACTIVITY_PERIOD) do
    where.not(id: User.joins(:experts).merge(Expert.with_activity(date_range)))
      .where.not(id: Feedback.where(updated_at: date_range).select(:user_id))
      .where.not(id: managers)
  end

  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('users.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :support_users, -> do
    joins(:experts)
      .merge(Expert.support_experts)
  end

  scope :currently_absent, -> {
    where('users.absence_start_at < ? AND users.absence_end_at > ?', Time.current, Time.current)
  }

  # Search
  scope :by_institution, -> (institution_slug) do
    joins(antenne: :institution)
      .where(antennes: { institutions: { slug: institution_slug } })
  end

  scope :by_name, -> (query) { not_deleted.where('users.full_name ILIKE ?', "%#{query}%") }

  scope :by_antenne, -> (antenne_id) { where(antenne: antenne_id) }

  scope :by_subject, -> (subject_id) do
    return all if subject_id.blank?
    joins(experts: :subjects).where(experts: { subjects: subject_id }).distinct
  end

  scope :by_theme, -> (theme_id) do
    return all if theme_id.blank?
    joins(experts: :themes).where(experts: { themes: theme_id }).distinct
  end

  # utilisé dans l'export en attendant de faire une version qui accepte plusieurs experts avec des sujets
  def expert_team_for_export
    experts.with_subjects.first || experts.first
  end

  scope :by_region, -> (region_code) do
    return if region_code.blank?
    joins(:antenne, :experts).where(antenne: Antenne.by_region(region_code)).merge(Expert.by_region(region_code))
  end

  scope :region_eq, -> (region_code) {
    by_region(region_code)
  }

  ## Password
  #
  # Before the invitation is (being) accepted, the password can (and in fact should) be nil.
  def password_required?
    if !accepting_invitation? && !invitation_accepted?
      false
    else
      super
    end
  end

  def password_complexity
    return if password.blank?
    check = CheckPasswordComplexity.new(password)
    return true if check.valid?

    errors.add :base, check.error_message
    false
  end

  # Override from Devise::Models::Recoverable:
  # * If the user has been invited, but hasn’t clicked the invitation link yet, resend them the invitation.
  # * Otherwise just send a password reset email.
  # (We also want Devise.paranoid to be true to prevent user enumeration.)
  def send_reset_password_instructions
    return if self.deleted?
    if invitation_accepted?
      super
    else
      invite!
    end
  end

  def invitation_not_accepted?
    invitation_accepted_at.nil?
  end

  def invite_to_demo
    UserMailer.with(user: self).invite_to_demo.deliver_later
    self.update(demo_invited_at: Time.zone.now)
  end

  ## Deactivation and soft deletion
  #
  def active_for_authentication?
    super && !deleted?
  end

  def soft_delete
    self.transaction do
      update_columns(SoftDeletable.persons_attributes)
      self.user_rights.destroy_all
    end
  end

  # Override from Devise::Validatable
  def email_required?
    !deleted?
  end

  def full_name
    # Overriding this getter has a side-effect: :full_name is required to be present by PersonConcern.
    # In #delete we set it to nil, but the result of this getter is used for the validation, which then passes.
    deleted? ? I18n.t('deleted_account.full_name') : self[:full_name]
  end

  ## Expert associations helpers
  #
  # Used for matches transfer
  def single_user_experts
    experts.with_one_user
  end

  def create_single_user_experts
    existing = single_user_experts.first
    return existing if existing.present?

    self.experts.create!(self.user_expert_shared_attributes)
  end

  def managed_cooperation
    self.managed_cooperations&.first
  end

  ## Rights

  def is_manager?
    user_rights_manager.any?
  end

  def is_cooperation_manager?
    user_rights_cooperation_manager.any?
  end

  def is_only_cooperation_manager?
    is_cooperation_manager? && experts.empty?
  end

  def is_admin?
    user_rights_admin.any?
  end

  def duplicate(params)
    params[:job] ||= self.job
    new_user = User.create(params.merge(antenne: antenne))
    return new_user unless new_user.valid?
    user_experts = self.experts
    if user_experts.present?
      new_user.experts.concat(user_experts)
      new_user.save
    end
    self.user_rights.each { |right| right.dup.update(user_id: new_user.id) }
    new_user
  end

  def supervised_antennes
    if self.is_manager?
      ids = self.managed_antennes.each_with_object([]) do |managed_antenne, array|
        array.push(*managed_antenne.territorial_antennes.pluck(:id))
      end
      ids.push(*self.managed_antenne_ids).uniq
      Antenne.where(id: ids)
    else
      # pour avoir une collection, utile dans certaines méthodes
      Antenne.where(id: self.antenne.id)
    end
  end

  def after_database_authentication
    self.update_columns(invitation_token: nil) if self.invitation_token.present?
  end

  def support_user
    if self.is_manager? && self.antenne.national?
      UserRight.category_main_referent.first&.user
    elsif self.is_cooperation_manager?
      self.managed_cooperations.first.support_user
    else
      self.antenne.support_user
    end
  end

  def fill_absence_start_at
    self.absence_start_at = Time.zone.now if self.absence_start_at.nil?
  end

  def add_shared_satisfactions
    AddSharedSatisfactionsJob.perform_later(self.id)
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "absence_start_at", "absence_end_at", "antenne_id", "cgu_accepted_at", "created_at", "current_sign_in_at", "current_sign_in_ip", "deleted_at", "email",
      "encrypted_password", "full_name", "id", "id_value", "invitation_accepted_at", "invitation_created_at",
      "invitation_limit", "invitation_sent_at", "invitation_token", "invitations_count", "inviter_id", "job",
      "last_sign_in_at", "last_sign_in_ip", "phone_number", "remember_created_at", "reset_password_sent_at",
      "reset_password_token", "sign_in_count", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "antenne", "csv_exports_attachments",
      "csv_exports_blobs", "experts", "feedbacks", "institution", "invited_by", "invitees", "inviter", "managed_antennes",
      "received_diagnoses", "received_matches", "received_needs", "sent_diagnoses", "sent_matches", "sent_needs",
      "themes", "user_rights",
      "user_rights_admin", "user_rights_manager"
    ]
  end

  def self.ransackable_scopes(auth_object = nil)
    ["region_eq"]
  end
end
