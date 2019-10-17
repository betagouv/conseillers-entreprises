# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deactivated_at         :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
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
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)
#  inviter_id             :bigint(8)
#
# Indexes
#
#  index_users_on_antenne_id            (antenne_id)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
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
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable, :async,
         :validatable,
         :invitable, invited_by_class_name: 'User', validate_on_invite: true

  ## Associations
  #
  belongs_to :antenne, counter_cache: :advisors_count, inverse_of: :advisors, optional: true
  has_and_belongs_to_many :experts, inverse_of: :users
  has_many :sent_diagnoses, class_name: 'Diagnosis', foreign_key: 'advisor_id', inverse_of: :advisor
  has_many :searches, dependent: :destroy, inverse_of: :user
  has_many :feedbacks, dependent: :destroy, inverse_of: :user
  belongs_to :inviter, class_name: 'User', inverse_of: :invitees, optional: true
  has_many :invitees, class_name: 'User', foreign_key: 'inviter_id', inverse_of: :inviter

  ## Validations
  #
  validates :full_name, :phone_number, presence: true

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
  has_many :received_matches, through: :experts, source: :received_matches, inverse_of: :contacted_users
  has_many :received_needs, through: :experts, source: :received_needs, inverse_of: :contacted_users
  has_many :received_diagnoses, through: :experts, source: :received_diagnoses, inverse_of: :contacted_users

  ## Scopes
  #
  scope :admin, -> { where(is_admin: true) }
  scope :not_admin, -> { where(is_admin: false) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }
  scope :email_not_confirmed, -> { where(confirmed_at: nil) }

  # Invitations scopes: TODO: `confirmable` is to be removed, related queries will be adjusted
  scope :not_invited_yet, -> do
    where(invitation_created_at: nil)
      .where(confirmation_sent_at: nil) # This will be removed
      .where(confirmed_at: nil)         # This will be removed
  end
  # :invitation_not_accepted and :invitation_accepted are declared in devise_invitable/model.rb

  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('users.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

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

  scope :without_antenne, -> do
    where(antenne_id: nil)
  end

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

  ## Deactivation
  #
  def active_for_authentication?
    super && !deactivated?
  end

  def inactive_message
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

  ## Administration helpers
  #
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

  def corresponding_antenne
    if self.experts.present?
      return self.experts.first.antenne
    end

    antennes = Antenne.joins(:experts)
      .distinct
      .where('experts.email ILIKE ?', "%#{self.email.split('@').last}")
    if antennes.one?
      return antennes.first
    end
  end

  def autolink_antenne!
    if self.antenne.nil?
      corresponding = self.corresponding_antenne
      if corresponding.present?
        self.antenne = corresponding
        self.save!
      end
    end
  end

  ##
  #
  def is_oneself?
    self.experts.size == 1 && self.experts.first.users == [self]
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

  def support_expert_skill
    ExpertSkill.support.find_by(expert: self.experts)
  end
end
