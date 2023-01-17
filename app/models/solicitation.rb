# == Schema Information
#
# Table name: solicitations
#
#  id                               :bigint(8)        not null, primary key
#  banned                           :boolean          default(FALSE)
#  code_region                      :integer
#  completed_at                     :datetime
#  created_in_deployed_region       :boolean          default(TRUE)
#  description                      :string
#  email                            :string
#  form_info                        :jsonb
#  full_name                        :string
#  landing_slug                     :string
#  location                         :string
#  phone_number                     :string
#  prepare_diagnosis_errors_details :jsonb
#  requested_help_amount            :string
#  siret                            :string
#  status                           :integer          default("step_contact")
#  uuid                             :uuid
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  institution_id                   :bigint(8)
#  landing_id                       :bigint(8)
#  landing_subject_id               :bigint(8)
#
# Indexes
#
#  index_solicitations_on_code_region         (code_region)
#  index_solicitations_on_email               (email)
#  index_solicitations_on_institution_id      (institution_id)
#  index_solicitations_on_landing_id          (landing_id)
#  index_solicitations_on_landing_slug        (landing_slug)
#  index_solicitations_on_landing_subject_id  (landing_subject_id)
#  index_solicitations_on_status              (status)
#  index_solicitations_on_uuid                (uuid)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#  fk_rails_...  (landing_id => landings.id)
#  fk_rails_...  (landing_subject_id => landing_subjects.id)
#

class Solicitation < ApplicationRecord
  include AASM
  include DiagnosisCreation::SolicitationMethods
  include RangeScopes

  ## Associations
  #
  belongs_to :landing, inverse_of: :solicitations, optional: true
  belongs_to :landing_subject, inverse_of: :solicitations, optional: true
  has_one :landing_theme, through: :landing_subject, source: :landing_theme, inverse_of: :landing_subjects
  has_one :subject, through: :landing_subject, source: :subject, inverse_of: :landing_subjects

  has_one :diagnosis, inverse_of: :solicitation
  has_many :diagnosis_regions, -> { regions }, through: :diagnosis, source: :facility_territories, inverse_of: :diagnoses
  has_one :facility, through: :diagnosis, source: :facility, inverse_of: :diagnoses

  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :matches, through: :diagnosis, inverse_of: :solicitation
  has_many :needs, through: :diagnosis, inverse_of: :solicitation
  belongs_to :institution, inverse_of: :solicitations, optional: true
  has_many :badge_badgeables, as: :badgeable
  has_many :badges, through: :badge_badgeables, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update
  has_many :institution_filters, dependent: :destroy, as: :institution_filtrable, inverse_of: :institution_filtrable
  accepts_nested_attributes_for :institution_filters, allow_destroy: false

  before_create :set_uuid
  before_create :set_institution_from_landing

  paginates_per 50

  GENERIC_EMAILS_TYPES = %i[bad_quality particular_retirement creation employee_labor_law siret moderation independent_tva intermediary recruitment_foreign_worker no_expert carsat tns_training]

  ## Status
  #

  enum status: {
    step_contact: 0, step_company: 1, step_description: 2,
    in_progress: 3, processed: 4, canceled: 5, step_verification: 6
  }, _prefix: true

  aasm :status, column: :status, enum: true do
    state :step_contact, initial: true
    state :step_company
    state :step_description
    state :step_verification
    state :in_progress
    state :processed
    state :canceled

    event :go_to_step_company do
      transitions from: [:step_contact], to: :step_company
    end

    event :go_to_step_description do
      transitions from: [:step_company], to: :step_description
    end

    event :go_to_step_verification do
      transitions from: [:step_description], to: :step_verification
    end

    event :complete, before: :format_solicitation do
      transitions from: [:step_description, :step_verification], to: :in_progress
    end

    event :process do
      transitions from: [:in_progress, :processed, :canceled], to: :processed, if: :diagnosis_completed?
    end

    event :cancel do
      # une solicitation peut être doublement canceled : "mauvais siret" qui se transforme en "hors région"
      transitions from: [:in_progress, :processed, :canceled], to: :canceled
    end
  end

  # State machine validations
  #
  def diagnosis_completed?
    self.diagnosis.step_completed?
  end

  def self.incompleted_statuses
    %w[step_contact step_company step_description step_verification]
  end

  def self.completed_statuses
    %w[in_progress processed canceled]
  end

  def step_complete?
    self.class.completed_statuses.include?(status)
  end

  ## Validations
  #
  validates :landing, presence: true, allow_blank: false
  # Il y a des solicitation sans landing_subject jusqu'en octobre 2020
  validates :landing_subject, presence: true, allow_blank: false, if: -> { created_at.nil? || created_at > "20201101".to_date }
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validates :institution_filters, presence: true, if: -> { subject_with_additional_questions? }
  validates :api_calling_url, presence: true, if: -> { landing&.api? }
  validates :completed_at, presence: true, if: -> { step_complete? }

  validate if: -> { status_step_contact? || status_step_company? || status_step_description? || landing&.api? } do
    contact_step_required_fields.each do |attr|
      errors.add(attr, :blank) if self.public_send(attr).blank?
    end
  end
  validate if: -> { status_step_description? || landing&.api? } do
    required_fields.each do |attr|
      errors.add(attr, :blank) if self.public_send(attr).blank?
    end
    # on ne vérifie la validité du siret qu'à cette étape, car on a bcp de vieille ou actuelles solicitations avec un siret invalide
    if company_step_is_siret? && siret.present?
      self.siret = FormatSiret.clean_siret(siret)
      errors.add(:siret, :must_be_a_valid_siret) unless FormatSiret.siret_is_valid(siret)
    end
  end
  validate if: -> { status_step_verification? || landing&.api? } do
    errors.add(:description, :blank) if (description.blank? || description == landing_subject&.description_prefill)
  end

  def subject_with_additional_questions?
    status_in_progress? && self.subject&.additional_subject_questions&.any?
  end

  ## Callbacks
  #
  def set_institution_from_landing
    self.institution ||= landing&.institution || Institution.find_by(slug: form_info&.fetch('institution', nil))
  end

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def touch_after_badges_update(_badge)
    touch if persisted?
  end

  def format_solicitation
    params = set_siret_and_region
    self.email = formatted_email
    self.siret = params[:siret]
    self.code_region = params[:code_region]
    self.completed_at = Time.zone.now
  end

  def formatted_email
    # cas des double point qui empêche l'envoi d'email
    self.email&.squeeze('.')
  end

  def set_siret_and_region
    params = { code_region: self.code_region, siret: self.siret }
    return params if (self.code_region.present? && self.code_region != 0)
    siret_or_siren = FormatSiret.clean_siret(siret)
    # Solicitation with a valid SIREN -> find siret
    if FormatSiret.siren_is_valid(siret_or_siren)
      begin
        response = ApiInsee::SiretsBySiren::Base.new(siret_or_siren).call
        return params if (response[:nombre_etablissements_ouverts] != 1)
        siret_or_siren = response.dig(:etablissements_ouverts, 0, 'siret')
      rescue ApiInsee::ApiInseeError => e
        return params
      end
    end
    # Solicitation with a valid SIRET
    if FormatSiret.siret_is_valid(siret_or_siren)
      begin
        etablissement_data = ApiEntreprise::Etablissement::Base.new(siret_or_siren).call
        return params if etablissement_data.blank?
        params[:code_region] = ApiConsumption::Models::Facility::ApiEntreprise.new(etablissement_data).code_region
        params[:siret] = siret_or_siren
      rescue ApiEntreprise::ApiEntrepriseError => e
        return params
      end
    end
    params
  end

  ## Scopes
  #
  scope :omnisearch, -> (query) do
    if query.present?
      where(id: have_badge(query))
        .or(where(id: have_landing_subject(query)))
        .or(where(id: have_landing_theme(query)))
        .or(where(id: have_landing(query)))
        .or(description_contains(query))
        .or(name_contains(query))
        .or(email_contains(query))
        .or(mtm_kwd_contains(query))
        .or(mtm_campaign_contains(query))
        .or(relaunch_contains(query))
    end
  end

  scope :have_badge, -> (query) do
    joins(:badges).where('badges.title ILIKE ?', "%#{query}%")
  end

  scope :have_landing_subject, -> (query) do
    joins(:landing_subject).where('landing_subjects.slug ILIKE ?', "%#{query}%")
  end

  scope :have_landing_theme, -> (query) do
    joins(:landing_theme).where('landing_themes.slug ILIKE ?', "%#{query}%")
  end

  scope :have_landing, -> (query) do
    joins(:landing).where('landings.slug ILIKE ?', "%#{query}%")
  end

  scope :description_contains, -> (query) do
    where('solicitations.description ILIKE ?', "%#{query}%")
  end

  scope :name_contains, -> (query) do
    where('solicitations.full_name ILIKE ?', "%#{query}%")
  end

  scope :email_contains, -> (query) do
    where('solicitations.email ILIKE ?', "%#{query}%")
  end

  scope :mtm_kwd_contains, -> (query) {
    where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "%#{query}%")
      .or(where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}%"))
  }

  scope :mtm_campaign_contains, -> (query) {
    where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "%#{query}%")
      .or(where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}%"))
  }

  scope :relaunch_contains, -> (query) {
    where("solicitations.form_info::json->>'relaunch' ILIKE ?", "%#{query}%")
      .or(where("solicitations.form_info::json->>'relaunch' ILIKE ?", "%#{query}%"))
  }

  # Pour ransack, en admin
  scope :mtm_campaign_equals, -> (query) {
    where('form_info @> ?', { pk_campaign: query }.to_json)
      .or(where('form_info @> ?', { mtm_campaign: query }.to_json))
  }

  scope :mtm_campaign_starts_with, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "#{query}%")
      .or(where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "#{query}%"))
  }

  scope :mtm_campaign_ends_with, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}")
      .or(where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "%#{query}"))
  }

  scope :relaunch_equals, -> (query) {
    where('form_info @> ?', { pk_campaign: query }.to_json)
  }

  scope :relaunch_starts_with, -> (query) {
    where("solicitations.form_info::json->>'relaunch' ILIKE ?", "#{query}%")
  }

  scope :relaunch_ends_with, -> (query) {
    where("solicitations.form_info::json->>'relaunch' ILIKE ?", "%#{query}")
  }

  scope :completion_eq, -> (query) do
    return self unless ['step_complete', 'step_incomplete'].include?(query)
    self.send(query)
  end

  def self.ransackable_scopes(auth_object = nil)
    [
      :mtm_campaign_contains, :mtm_campaign_equals, :mtm_campaign_starts_with, :mtm_campaign_ends_with,
      :mtm_kwd_contains, :mtm_kwd_equals, :mtm_kwd_starts_with, :mtm_kwd_ends_with,
      :relaunch_contains, :relaunch_equals, :relaunch_ends_with, :relaunch_starts_with, :completion_eq
    ]
  end

  scope :without_diagnosis, -> {
    left_outer_joins(:diagnosis)
      .where(diagnoses: { id: nil })
  }

  # /!\ Fonctionne pas tout à fait, des solicitations avec matches ressortent (une vingtaine)
  scope :without_matches, -> {
    where.missing(:matches)
  }

  scope :step_complete, -> { where(status: completed_statuses) }
  scope :step_incomplete, -> { where(status: incompleted_statuses) }

  scope :of_campaign, -> (campaign) do
    where("form_info->>'pk_campaign' = ?", campaign)
      .or(where("form_info->>'mtm_campaign' = ?", campaign))
  end

  scope :in_regions, -> (codes_regions) do
    where(code_region: codes_regions)
  end

  scope :in_deployed_regions, -> do
    where(created_in_deployed_region: true)
  end

  # solicitation avec region identifiee mais hors region deployee
  scope :in_undeployed_regions, -> do
    where(created_in_deployed_region: false).where.not(code_region: nil)
  end

  scope :out_of_regions, -> (codes_regions) do
    where.not(code_region: codes_regions).where.not(code_region: nil)
  end

  scope :in_unknown_region, -> { where(code_region: nil) }

  # scope destiné à recevoir les solicitations qui ne sortent pas
  # dans les autres filtres des solicitation.
  # La méthode d'identification pourra evoluer au fil du temps
  scope :uncategorisable, -> { in_unknown_region }

  # param peut être un id de Territory ou une clé correspondant à un scope ("uncategorisable" par ex)
  scope :by_possible_region, -> (param) {
    begin
      in_regions(Territory.find(param).code_region)
    rescue ActiveRecord::RecordNotFound => e
      self.send(param)
    end
  }

  scope :out_of_deployed_territories, -> {
    out_of_regions(Territory.deployed_codes_regions)
  }

  # Solicitations similaires
  #
  scope :from_same_company, -> (solicitation) {
    where(siret: solicitation.valid_sirets)
      .or(where(email: solicitation.email))
  }

  scope :banned, -> { where(banned: true) }

  def doublon_solicitations
    Solicitation.where(status: [:in_progress])
      .where.not(id: self.id)
      .from_same_company(self)
      .uniq
  end

  def from_banned_company?
    banned? || Solicitation.from_same_company(self).banned.any?
  end

  def from_no_register_company?
    company = self&.facility&.company
    return false if company.nil?
    !company.inscrit_rcs && !company.inscrit_rm
  end

  def recent_matched_solicitations
    Solicitation.processed
      .where.not(id: self.id)
      .created_between(3.weeks.ago, Time.zone.now)
      .where(landing_subject_id: self.landing_subject_id)
      .from_same_company(self)
      .uniq
  end

  # Trouver les sirets probables des solicitations pour identifier relances et doublons
  def valid_sirets
    sirets = []
    sirets << self.facility.siret if self.facility.present?

    clean_siret = FormatSiret.clean_siret(self.siret)
    sirets << clean_siret if FormatSiret.siret_is_valid(clean_siret)

    contact = Contact.find_by(email: self.email)
    sirets << contact.company.facilities.pluck(:siret) if contact.present?
    sirets.flatten.compact.uniq
  end

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[pk_campaign pk_kwd gclid mtm_campaign mtm_kwd api_calling_url relaunch]
  store_accessor :form_info, FORM_INFO_KEYS.map(&:to_s)

  ##
  # Development helper
  def self.new(attributes = nil, &block)
    record = super
    if Rails.env.development? && ENV['DEVELOPMENT_PREFILL_SOLICITATION_FORM'].to_b
      record.assign_attributes(
        description: 'Ceci est un test',
        siret: '200 054 948 00019',
        full_name: 'Marie Dupont',
        phone_number: '01 23 46 78 90',
        email: 'marie.dupont@exemple.fr'
      )
    end
    record
  end

  ## Visible fields in form
  #
  BASE_REQUIRED_FIELDS = %i[full_name phone_number email]
  DEFAULT_REQUIRED_FIELDS = %i[full_name phone_number email siret]

  def contact_step_required_fields
    BASE_REQUIRED_FIELDS
  end

  def company_step_required_fields
    landing_subject&.required_fields || %i[siret]
  end

  def company_step_is_siret?
    company_step_required_fields == [:siret]
  end

  def required_fields
    contact_step_required_fields + company_step_required_fields
  end

  FIELD_TYPES = {
    full_name: 'text',
    phone_number: 'tel',
    email: 'email',
    siret: 'text',
    requested_help_amount: 'text',
    location: 'text'
  }

  AUTOCOMPLETE_TYPES = {
    full_name: 'name',
    phone_number: 'tel',
    email: 'email'
  }

  ## Preselection
  #
  def preselected_subject
    landing_subject&.subject
  end

  def normalized_phone_number
    number = phone_number&.gsub(/[^0-9]/,'')
    if number.present? && number.length == 10
      number.gsub(/(.{2})(?=.)/, '\1 \2')
    else
      phone_number
    end
  end

  # Provenance
  #
  def provenance_category
    if landing&.iframe?
      :iframe
    elsif landing&.api?
      :api
    elsif pk_campaign&.start_with?('googleads-') || mtm_campaign&.start_with?('googleads-')
      :googleads
    elsif pk_campaign.present? || mtm_campaign.present?
      :campaign
    end
  end

  def from_iframe?
    provenance_category == :iframe
  end

  def from_api?
    provenance_category == :api
  end

  def from_campaign?
    provenance_category == :campaign || provenance_category == :googleads
  end

  def from_relaunch?
    relaunch.present?
  end

  def provenance_title
    if from_iframe?
      landing.slug
    elsif from_api?
      landing.partner_url
    elsif from_campaign?
      campaign
    end
  end

  def provenance_detail
    if from_campaign?
      pk_kwd.presence || mtm_kwd.presence
    elsif from_api?
      api_calling_url
    end
  end

  def campaign
    pk_campaign.presence || mtm_campaign.presence
  end

  # Else ---------------------
  def to_s
    "#{self.class.model_name.human} #{id}"
  end

  def display_attributes
    %i[normalized_phone_number institution requested_help_amount location provenance_title provenance_detail relaunch]
  end

  def normalized_siret
    siret.gsub(/(\d{3})(\d{3})(\d{3})(\d*)/, '\1 \2 \3 \4')
  end

  def transmitted_at
    diagnosis&.completed_at
  end

  def region
    return if code_region.nil?
    Territory.find_by(code_region: self.code_region)
  end
end
