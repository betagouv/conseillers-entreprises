# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  cgu_accepted_at        :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  full_name              :string
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  job                    :string
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
  include PersonConcern
  include InvolvementConcern
  include SoftDeletable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :async,
         :validatable,
         :invitable, invited_by_class_name: 'User', validate_on_invite: true

  attr_accessor :cgu_accepted, :specifics_territories

  ## Associations
  #
  belongs_to :antenne, inverse_of: :advisors

  has_and_belongs_to_many :experts, -> { not_deleted }, inverse_of: :users

  has_many :sent_diagnoses, class_name: 'Diagnosis', foreign_key: 'advisor_id', inverse_of: :advisor
  has_many :searches, inverse_of: :user
  has_many :feedbacks, inverse_of: :user
  belongs_to :inviter, class_name: 'User', inverse_of: :invitees, optional: true
  has_many :invitees, class_name: 'User', foreign_key: 'inviter_id', inverse_of: :inviter, counter_cache: :invitations_count
  has_many :supported_territories, class_name: 'Territory', foreign_key: 'support_contact_id', inverse_of: :support_contact

  # :rights / roles
  has_many :user_rights, inverse_of: :user
  has_many :user_rights_manager, ->{ category_manager }, class_name: 'UserRight', inverse_of: :user
  has_many :user_rights_admin, ->{ category_admin }, class_name: 'UserRight', inverse_of: :user
  has_many :managed_antennes, through: :user_rights_manager, source: :antenne, inverse_of: :managers
  accepts_nested_attributes_for :user_rights, allow_destroy: true

  ## Validations
  #
  validates :full_name, presence: true, unless: :deleted?
  validates :job, presence: true
  validate :password_complexity
  after_create :create_personal_skillset_if_needed
  after_update :synchronize_personal_skillsets
  validates_associated :experts, on: :import

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
  has_and_belongs_to_many :relevant_experts, -> { relevant_for_skills }, class_name: 'Expert'
  has_many :regions, through: :experts, inverse_of: :advisors

  ## Scopes
  #
  scope :admin, -> { not_deleted.joins(:user_rights).merge(UserRight.category_admin) }
  scope :managers, -> { not_deleted.joins(:user_rights).merge(UserRight.category_manager) }

  scope :not_invited, -> { not_deleted.where(invitation_sent_at: nil) }
  scope :managers_not_invited, -> { not_deleted.managers.where(invitation_sent_at: nil) }
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

  # Search
  scope :by_institution, -> (institution_slug) do
    joins(antenne: :institution)
      .where(antennes: { institutions: { slug: institution_slug } })
  end

  scope :by_name, -> (query) { not_deleted.where('users.full_name ILIKE ?', "%#{query}%") }

  scope :by_antenne, -> (antenne_id) { where(antenne: antenne_id) }

  scope :by_region, -> (region_id) { joins(antenne: { communes: :territories }).where(antenne: { communes: { territories: { id: region_id } } }).distinct }

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

  ## Relevant Experts stuff
  # User objects fetched through this scope have an additional attribute :relevant_expert_id
  # Note: This scope will return DUPLICATE ROWS FOR THE SAME USER, if there are several relevant experts.)
  scope :relevant_for_skills, -> do
    not_deleted
      .joins(:relevant_experts)
      .select('users.*', 'experts.id as relevant_expert_id', 'experts.full_name as team_name')
  end
  # User objects fetched through relevant_for_skills have an addition association to a single expert.
  # This makes it possible to preload it in views.
  belongs_to :relevant_expert, class_name: 'Expert', optional: true

  scope :in_region, -> (region_id) do
    left_joins(antenne: :regions)
      .left_joins(:experts)
      .select('"antennes".*, "users".*')
      .where(antennes: { territories: { id: [region_id] } })
      .or(self.select('"antennes".*, "users".*').where(experts: { is_global_zone: true }))
      .distinct
  end

  ## Search
  #
  scope :omnisearch, -> (query) do
    if query.present?
      by_name(query)
    end
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
    if invitation_sent_at.present? && invitation_accepted_at.nil?
      invite!
    else
      super
    end
  end

  def invitation_not_accepted?
    invitation_accepted_at.nil?
  end

  ## Deactivation and soft deletion
  #
  def active_for_authentication?
    super && !deleted?
  end

  # Suppression de l'utilisateur + personal_skillsets
  def soft_delete
    self.transaction do
      personal_skillsets.each { |e| e.update_columns(SoftDeletable.persons_attributes) }
      update_columns(SoftDeletable.persons_attributes)
    end
  end

  # Suppression de l'utilisateur + tous ses experts solo
  def deep_soft_delete
    self.transaction do
      experts.each do |expert|
        next if expert.users.many?
        expert.update_columns(SoftDeletable.persons_attributes)
      end
      update_columns(SoftDeletable.persons_attributes)
    end
  end

  def email_required? # Override from Devise::Validatable
    !deleted?
  end

  def full_name
    # Overriding this getter has a side-effect: :full_name is required to be present by PersonConcern.
    # In #delete we set it to nil, but the result of this getter is used for the validation, which then passes.
    deleted? ? I18n.t('deleted_account.full_name') : self[:full_name]
  end

  ## Expert associations helpers
  #
  def personal_skillsets
    experts.personal_skillsets
  end

  def attributes_shared_with_personal_skills
    shared_attributes = %w[email full_name phone_number job antenne_id]
    self.attributes.slice(*shared_attributes)
  end

  def create_personal_skillset_if_needed
    return if personal_skillsets.present?

    self.experts.create!(self.attributes_shared_with_personal_skills)
  end

  # Bizarrement, qq utilisateurs sont créés sans personal_skillsets (investigation en cours)
  def synchronize_personal_skillsets
    user_personal_skillsets = personal_skillsets.presence ||
      self.experts.where(full_name: self.full_name).or(self.experts.where(email: self.email))
    if user_personal_skillsets.present?
      user_personal_skillsets.update_all(self.attributes_shared_with_personal_skills)
    else
      self.experts.create!(self.attributes_shared_with_personal_skills)
    end
  end

  ## Rights

  def is_manager?
    user_rights_manager.any?
  end

  def is_admin?
    user_rights_admin.any?
  end

  def duplicate(params)
    params[:job] = params[:job].presence || self.job
    new_user = User.create(params.merge(antenne: antenne))
    user_experts = self.relevant_experts - self.personal_skillsets
    # si c'est une équipe
    if user_experts.present?
      new_user.relevant_experts = user_experts
      new_user.save
    # si c'est un expert personnel on attribue les sujets à l'expert personnel du nouvel utilisateur
    elsif self.personal_skillsets.map(&:experts_subjects).present?
      self.personal_skillsets.first.experts_subjects.map do |es|
        ExpertSubject.create(institution_subject: es.institution_subject,
                             expert: new_user.personal_skillsets.first,
                             intervention_criteria: es.intervention_criteria)
      end
      # et les territoires spécifiques si on a coché l'option
      if params[:specifics_territories].to_b
        new_user.personal_skillsets.first.communes = self.personal_skillsets.first.communes
      end
    end
    self.user_rights.each { |right| right.dup.update(user_id: new_user.id) }
    new_user
  end

  def transfer_matches_to(user)
    personal_skillset = self.personal_skillsets.first
    begin
      raise StandardError.new(I18n.t('activerecord.attributes.user.have_not_personal_skillsets', user: self)) if personal_skillset.nil?
      ActiveRecord::Base.transaction do
        personal_skillset.received_matches.in_progress.each do |match|
          match.update(expert: user.personal_skillsets.first)
        end
      end
    rescue StandardError => e
      StandardError.new(I18n.t('activerecord.attributes.user.errors.cant_transfer_match', error: e.message))
    end
  end
end
