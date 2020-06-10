# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deactivated_at         :datetime
#  deleted_at             :datetime
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  flags                  :jsonb
#  full_name              :string
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  is_admin               :boolean          default(FALSE), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  phone_number           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string
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
  include PersonConcern
  include InvolvementConcern
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :async,
         :validatable,
         :invitable, invited_by_class_name: 'User', validate_on_invite: true

  ## Associations
  #
  belongs_to :antenne, counter_cache: :advisors_count, inverse_of: :advisors
  has_and_belongs_to_many :experts, inverse_of: :users
  has_many :sent_diagnoses, class_name: 'Diagnosis', foreign_key: 'advisor_id', inverse_of: :advisor
  has_many :searches, inverse_of: :user
  has_many :feedbacks, inverse_of: :user
  belongs_to :inviter, class_name: 'User', inverse_of: :invitees, optional: true
  has_many :invitees, class_name: 'User', foreign_key: 'inviter_id', inverse_of: :inviter, counter_cache: :invitations_count

  ## Validations
  #
  validates :full_name, :phone_number, presence: true, unless: :deleted?
  after_create :create_personal_skillset_if_needed
  after_update :synchronize_personal_skillsets

  def ensure_has_expert
    create_matching_expert
  end

  ## “Through” Associations
  #
  # :antenne
  has_one :institution, through: :antenne, source: :institution, inverse_of: :advisors
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :advisors
  has_many :antenne_territories, through: :antenne, source: :territories, inverse_of: :advisors

  # :sent_diagnoses
  has_many :sent_needs, through: :sent_diagnoses, source: :needs, inverse_of: :advisor
  has_many :sent_matches, through: :sent_diagnoses, source: :matches, inverse_of: :advisor

  # :experts
  has_many :received_matches, -> { sent }, through: :experts, source: :received_matches, inverse_of: :contacted_users
  has_many :received_needs, through: :experts, source: :received_needs, inverse_of: :contacted_users
  has_many :received_diagnoses, through: :experts, source: :received_diagnoses, inverse_of: :contacted_users
  has_and_belongs_to_many :relevant_experts, -> { relevant_for_skills }, class_name: 'Expert'

  ## Scopes
  #
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }

  scope :admin, -> { where(is_admin: true) }
  scope :not_admin, -> { where(is_admin: false) }

  scope :never_used, -> { where(invitation_sent_at: nil).where(encrypted_password: '') }
  # :invitation_not_accepted and :invitation_accepted are declared in devise_invitable/model.rb

  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('users.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :support_users, -> do
    joins(:experts)
      .merge(Expert.support_experts)
  end

  # Team stuff
  scope :single_expert, -> { joins(:experts).group(:id).having('COUNT(experts.id)=1') }
  scope :team_members, -> { not_deleted.joins(:experts).merge(Expert.teams) }
  scope :no_team, -> { not_deleted.where.not(id: unscoped.team_members) }
  # A user without experts is not supposed to happen:
  # `create_personal_skillset_if_needed` makes sure there is one after a user is created.
  # However there is nothing preventing an expert to be removed afterwards.
  # This can reasonably happen when expert teams are reorganized.
  scope :without_experts, -> { left_outer_joins(:experts).where(experts: { id: nil }) }

  # Activity
  scope :active_searchers, -> (date) do
    joins(:searches)
      .merge(Search.where(created_at: date))
      .distinct
  end

  scope :active_diagnosers, -> (date, minimum_step) do
    joins(:sent_diagnoses)
      .merge(Diagnosis.archived(false)
        .where(created_at: date)
        .after_step(minimum_step))
      .distinct
  end

  scope :active_matchers, -> (date) do
    joins(sent_diagnoses: [needs: :matches])
      .merge(Diagnosis.archived(false)
        .where(created_at: date))
      .distinct
  end

  scope :active_answered, -> (date, status) do
    joins(sent_diagnoses: [needs: :matches])
      .merge(Match
        .where(taken_care_of_at: date)
        .where(status: status))
      .distinct
  end

  ## Keys for flags preferences
  #
  FLAGS = %i[
    can_view_review_subjects_flash
    can_view_diagnoses_tab
    disable_email_confirm_notifications_sent
  ]
  store_accessor :flags, FLAGS.map(&:to_s)

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

  # Override from Devise::Models::DatabaseAuthenticatable
  def update_without_password(params, *options)
    params.delete(:email)
    super(params)
  end

  # Override from Devise::Models::Recoverable:
  # * If the user has been invited, but hasn’t clicked the invitation link yet, resend them the invitation.
  # * Otherwise just send a password reset email.
  # (We also want Devise.paranoid to be true to prevent user enumeration.)
  def send_reset_password_instructions
    if invitation_sent_at.present? && invitation_accepted_at.nil?
      invite!
    else
      super
    end
  end

  def never_used_account?
    invitation_sent_at.nil? && encrypted_password.blank?
  end

  ## Deactivation and soft deletion
  #
  def active_for_authentication?
    super && !deactivated? && !deleted?
  end

  def inactive_message # override for Devise::Authenticatable
    deactivated_at.present? ? :deactivated : super
  end

  def deactivated?
    deactivated_at.present?
  end

  def deactivate!
    update(deactivated_at: Time.zone.now)
  end

  def reactivate!
    update(deactivated_at: nil)
  end

  def delete
    self.transaction do
      personal_skillsets.each { |expert| expert.delete }
      update(deleted_at: Time.zone.now,
        email: nil,
        full_name: nil,
        phone_number: nil)
    end
  end

  def destroy
    # Don’t really destroy!
    # callbacks for :destroy are not run
    delete
  end

  def deleted?
    deleted_at.present?
  end

  def email_required? # Override from Devise::Validatable
    !deleted?
  end

  def full_name
    # Overriding this getter has a side-effect: :full_name is required to be present by PersonConcern.
    # In #delete we set it to nil, but the result of this getter is used for the validation, which then passes.
    deleted? ? I18n.t('deleted_account.full_name') : self[:full_name]
  end

  def full_name_with_role
    "#{full_name} - #{full_role}"
  end

  def full_role
    if antenne.present?
      "#{role} - #{antenne.name}"
    else
      "#{role}"
    end
  end

  def is_support_user?
    ExpertSubject.where(expert: self.experts).support.present?
  end

  def personal_skillsets
    experts.personal_skillsets
  end

  def attributes_shared_with_personal_skills
    shared_attributes = %w[email full_name phone_number role antenne_id]
    self.attributes.slice(*shared_attributes)
  end

  def create_personal_skillset_if_needed
    return if personal_skillsets.present?

    self.experts.create!(self.attributes_shared_with_personal_skills)
  end

  def synchronize_personal_skillsets
    self.personal_skillsets.update_all(self.attributes_shared_with_personal_skills)
  end
end
