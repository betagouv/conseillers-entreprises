# == Schema Information
#
# Table name: solicitations
#
#  id                               :bigint(8)        not null, primary key
#  code_region                      :integer
#  completed_at                     :datetime
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
  include RangeScopes

  ## Associations
  #
  belongs_to :landing, inverse_of: :solicitations, optional: true
  belongs_to :landing_subject, inverse_of: :solicitations, optional: true
  has_one :landing_theme, through: :landing_subject, source: :landing_theme, inverse_of: :landing_subjects
  has_one :subject, through: :landing_subject, source: :subject, inverse_of: :landing_subjects
  has_one :theme, through: :subject, source: :theme, inverse_of: :subjects

  has_one :diagnosis, inverse_of: :solicitation
  has_many :diagnosis_regions, -> { regions }, through: :diagnosis, source: :facility_territories, inverse_of: :diagnoses
  has_one :facility, through: :diagnosis, source: :facility, inverse_of: :diagnoses
  has_one :visitee, through: :diagnosis, source: :visitee, inverse_of: :diagnoses
  has_one :company, through: :facility, source: :company, inverse_of: :facilities

  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :matches, through: :diagnosis, inverse_of: :solicitation
  has_many :company_satisfactions, through: :diagnosis, inverse_of: :solicitation
  has_many :needs, through: :diagnosis, inverse_of: :solicitation
  belongs_to :institution, inverse_of: :solicitations, optional: true
  has_many :badge_badgeables, as: :badgeable
  has_many :badges, through: :badge_badgeables, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update
  has_many :subject_answers, dependent: :destroy, as: :subject_questionable, inverse_of: :subject_questionable, class_name: 'SubjectAnswer::Item'
  accepts_nested_attributes_for :subject_answers, allow_destroy: false

  before_create :set_uuid
  before_create :set_institution_from_landing

  after_update :update_diagnosis

  paginates_per 25

  GENERIC_EMAILS_TYPES = %i[
    bad_quality creation employee_labor_law siret moderation sie_tva_and_others
    sie_sip_declare_and_pay intermediary recruitment_foreign_worker no_expert carsat tns_training kbis_extract
    retirement_liberal_professions formalites_asso_agri_sci mediateurs
  ]

  ## Status
  #

  enum status: {
    step_contact: 0, step_company: 1, step_description: 2,
    in_progress: 3, processed: 4, canceled: 5
  }, _prefix: true

  aasm :status, column: :status, enum: true do
    state :step_contact, initial: true
    state :step_company
    state :step_description
    state :in_progress
    state :processed
    state :canceled

    event :go_to_step_company do
      transitions from: [:step_contact], to: :step_company
    end

    event :go_to_step_description do
      transitions from: [:step_company], to: :step_description
    end

    event :complete, before: :format_solicitation do
      # canceled : cas des mauvaises qualités modifiés par le chef d'entreprise
      transitions from: [:step_description, :canceled], to: :in_progress, guard: :not_spam?
      transitions from: :step_description, to: :canceled, after: :tag_as_spam
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
    %w[step_contact step_company step_description]
  end

  def self.completed_statuses
    %w[in_progress processed canceled]
  end

  def self.unmodifiable_statuses
    %w[in_progress processed]
  end

  def step_complete?
    self.class.completed_statuses.include?(status)
  end

  def step_unmodifiable?
    self.class.unmodifiable_statuses.include?(status)
  end

  ## Validations
  #
  validates :landing, presence: true, allow_blank: false
  # Il y a des solicitation sans landing_subject jusqu'en octobre 2020
  validates :landing_subject, presence: true, allow_blank: false, if: -> { created_at.nil? || created_at > "20201101".to_date }
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validates :subject_answers, presence: true, if: -> { subject_with_additional_questions? }
  validate :correct_subject_answers, if: -> { subject_with_additional_questions? }
  # Todo : à décommenter une fois que la migration api_url est passée
  # validates :origin_url, presence: true, if: -> { landing&.api? }
  validates :completed_at, presence: true, if: -> { step_complete? }

  # Todo : à supprimer une fois que la migration api_url est passée ?
  validate if: -> { landing&.api? } do
    errors.add(:origin_url, :blank) if (self.origin_url.blank? || self.api_calling_url.blank?)
  end

  validate if: -> { status_step_contact? || status_step_company? || status_step_description? || landing&.api? } do
    contact_step_required_fields.each do |attr|
      errors.add(attr, :blank) if self.public_send(attr).blank?
    end
  end
  validate if: -> { status_step_description? || landing&.api? } do
    required_fields.each do |attr|
      errors.add(attr, :blank) if self.public_send(attr).blank?
    end
    # on ne vérifie la validité du siret qu'à cette étape, car on a bcp de vieilles solicitations avec un siret invalide
    if company_step_is_siret? && siret.present?
      self.siret = FormatSiret.clean_siret(siret)
      if !FormatSiret.siret_is_valid(siret)
        errors.add(:siret, :must_be_a_valid_siret)
      # On recale les siret étrangers
      elsif code_region.blank? || code_region == 0
        begin
          etablissement_data = ApiConsumption::Facility.new(siret, { request_keys: [] }).call
          foreign_country = etablissement_data.adresse['libelle_pays_etranger']
          if foreign_country.present?
            errors.add(:base, I18n.t('api_requests.foreign_facility', country: foreign_country.capitalize))
          else
            # on en profite pour mettre à jour le code_region si siret non diffusible
            self.code_region = etablissement_data.code_region
            self.siret = etablissement_data.siret
          end
        rescue StandardError
          true
        end
      end
    end
  end

  validate if: -> { status_in_progress? || landing&.api? } do
    errors.add(:description, :blank) if (description.blank? || description == landing_subject&.description_prefill)
  end

  def subject_with_additional_questions?
    status_in_progress? && self.subject&.subject_questions&.any?
  end

  def correct_subject_answers
    if (self.subject_answers.to_set{ |f| f.subject_question_id } != self.subject&.subject_question_ids.to_set)
      errors.add(:subject_answers, :incorrect)
    end
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
    self.email = formatted_email
    self.completed_at = Time.zone.now
  end

  def formatted_email
    # cas des double point qui empêche l'envoi d'email
    self.email&.squeeze('.')
  end

  ## Scopes
  #
  scope :omnisearch, -> (query) do
    if query.present?
      where(id: have_badge(query))
        .or(where(id: have_landing_subject(query)))
        .or(where(id: have_landing_theme(query)))
        .or(where(id: have_landing(query)))
        .or(description_cont(query))
        .or(name_cont(query))
        .or(email_cont(query))
        .or(siret_cont(query))
        .or(mtm_kwd_cont(query))
        .or(mtm_campaign_cont(query))
        .or(relaunch_cont(query))
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

  scope :description_cont, -> (query) do
    where('solicitations.description ILIKE ?', "%#{query}%")
  end

  scope :name_cont, -> (query) do
    where('solicitations.full_name ILIKE ?', "%#{query}%")
  end

  scope :email_cont, -> (query) do
    where('solicitations.email ILIKE ?', "%#{query}%")
  end

  scope :siret_cont, -> (query) do
    where('solicitations.siret ILIKE ?', "%#{query}%")
  end

  scope :relaunch_cont, -> (query) {
    where("solicitations.form_info::json->>'relaunch' ILIKE ?", "%#{query}%")
  }

  # Pour ransack, en admin
  scope :mtm_campaign_eq, -> (query) {
    where('form_info @> ?', { pk_campaign: query }.to_json)
      .or(where('form_info @> ?', { mtm_campaign: query }.to_json))
  }

  scope :mtm_campaign_start, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "#{query}%")
      .or(where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "#{query}%"))
  }

  scope :mtm_campaign_end, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}")
      .or(where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "%#{query}"))
  }

  scope :mtm_campaign_cont, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}%")
      .or(where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "%#{query}%"))
  }

  scope :mtm_kwd_eq, -> (query) {
    where('form_info @> ?', { pk_kwd: query }.to_json)
      .or(where('form_info @> ?', { mtm_kwd: query }.to_json))
  }

  scope :mtm_kwd_start, -> (query) {
    where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "#{query}%")
      .or(where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "#{query}%"))
  }

  scope :mtm_kwd_end, -> (query) {
    where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}")
      .or(where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "%#{query}"))
  }

  scope :mtm_kwd_cont, -> (query) {
    where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}%")
      .or(where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "%#{query}%"))
  }

  # pragmatisme : pas réussi à bien faire fonctionner le filtre relaunch_eq, mais filtre utilisé automatiquement en admin
  scope :relaunch_eq, -> (query) {
    relaunch_cont(query)
  }

  scope :relaunch_start, -> (query) {
    where("solicitations.form_info::json->>'relaunch' ILIKE ?", "#{query}%")
  }

  scope :relaunch_end, -> (query) {
    where("solicitations.form_info::json->>'relaunch' ILIKE ?", "%#{query}")
  }

  scope :completion_eq, -> (query) do
    return self unless ['step_complete', 'step_incomplete'].include?(query)
    self.send(query)
  end

  def self.ransackable_scopes(auth_object = nil)
    [
      :mtm_campaign_cont, :mtm_campaign_eq, :mtm_campaign_start, :mtm_campaign_end,
      :mtm_kwd_cont, :mtm_kwd_eq, :mtm_kwd_start, :mtm_kwd_end,
      :relaunch_cont, :relaunch_eq, :relaunch_end, :relaunch_start, :completion_eq
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

  # Solicitations similaires
  #
  scope :from_same_company, -> (solicitation) {
    if solicitation.siret.present?
      where(siret: solicitation.valid_sirets)
        .or(where(email: solicitation.email))
    else
      where(email: solicitation.email)
    end
  }

  def self.apply_filters(params)
    klass = self
    klass = klass.by_possible_region(params[:by_region]) if params[:by_region].present?
    klass = klass.omnisearch(params[:omnisearch]) if params[:omnisearch].present?
    klass.all
  end

  ## Diagnosis preparation

  def may_prepare_diagnosis?
    self.preselected_subject.present? &&
      FormatSiret.siret_is_valid(FormatSiret.clean_siret(self.siret))
  end

  # diagnosis_errors peut être un ActiveModel::Errors ou un Hash (erreur API)
  def prepare_diagnosis_errors=(diagnosis_errors)
    p "prepare_diagnosis_errors= (details)"
    p diagnosis_errors
    error_details = diagnosis_errors.is_a?(Hash) ? diagnosis_errors : diagnosis_errors&.details
    self.prepare_diagnosis_errors_details = error_details
  end

  def prepare_diagnosis_errors
    prepare_diagnosis_errors_details
  end

  def prepare_diagnosis_errors_to_s
    prepare_diagnosis_errors.flat_map do |attr, errors|
      pp attr
      pp errors
      if ['major', 'minor', 'unreachable_apis'].include?(attr)
        errors.flat_map do |key, value|
          [I18n.t(key, scope: 'api_name'), value].join(' : ')
        end
      elsif ['standard'].include?(attr)
        errors
      elsif ["basic_errors"].include?(attr)
        []
      else
        diagnosis_errors = Diagnosis.new.errors
        errors.each { |h| h.each_value { |error| diagnosis_errors.add(attr, error.to_sym) } }
        diagnosis_errors.full_messages
      end
    end
  end

  def doublon_solicitations
    Solicitation.where(status: [:in_progress])
      .where.not(id: self.id)
      .from_same_company(self)
      .uniq
  end

  def from_intermediary?
    facility = self&.facility
    return false if facility.nil?
    intermediary_naf_codes = %w[7022Z 6920Z 9411Z 8299Z 7021Z 9499Z 8413Z]
    intermediary_naf_codes.include?(facility.naf_code&.delete('.'))
  end

  def recent_matched_solicitations
    Solicitation.processed
      .where.not(id: self.id)
      .created_between(3.weeks.ago, Time.zone.now)
      .where(landing_subject_id: self.landing_subject_id)
      .from_same_company(self)
      .distinct
  end

  def similar_abandonned_solicitations
    Solicitation.where(status: [:canceled])
      .where.not(id: self.id)
      .from_same_company(self)
      .uniq
  end

  def update_diagnosis
    return if diagnosis.nil?
    return if status_processed?
    diagnosis.update(content: self.description) if description_previously_changed?
    visitee.update(
      email: email,
      full_name: full_name,
      phone_number: phone_number
    ) if (email_previously_changed? || full_name_previously_changed? || phone_number_previously_changed?) && visitee.present?
  end

  # Trouver les sirets probables des solicitations pour identifier relances et doublons
  def valid_sirets
    sirets = []
    sirets << self.facility.siret if self.facility.present?

    clean_siret = FormatSiret.clean_siret(self.siret)
    sirets << clean_siret if FormatSiret.siret_is_valid(clean_siret)
    # concaténation qui supprime les doublons
    sirets | Facility.for_contacts(email).pluck(:siret)
  end

  ## JSON Accessors
  #
  MATOMO_KEYS = %i[pk_campaign pk_kwd mtm_campaign mtm_kwd]
  # Paramètres qu'il est possible de passer dans l'url des iframes pour pré-remplir
  PREFILL_PARAMS = %i[full_name phone_number email siret]
  # TODO remove api_calling_url
  FORM_INFO_KEYS = MATOMO_KEYS + %i[gclid api_calling_url relaunch origin_title origin_id origin_url]
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

  def provenance_title_sanitized
    return nil if provenance_title.nil?
    provenance_title[/googleads/i] || provenance_title
  end

  def provenance_detail
    if from_campaign?
      pk_kwd.presence || mtm_kwd.presence
    elsif origin_title.present?
      origin_title
    elsif origin_url.present?
      origin_url
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

  def spam?
    Spam.find_by(email: email).present?
  end

  def not_spam?
    !spam?
  end

  def tag_as_spam
    tag = Badge.find_or_create_by(title: 'Spam', category: 'solicitations')
    self.badges << tag
  end

  def mark_as_spam
    Spam.find_or_create_by(email: email)
    self.cancel!
    tag_as_spam
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "code_region", "completed_at", "created_at", "description", "email", "form_info", "full_name", "id", "id_value",
      "institution_id", "landing_id", "landing_slug", "landing_subject_id", "location", "phone_number",
      "prepare_diagnosis_errors_details", "requested_help_amount", "siret", "status", "updated_at", "uuid", "mtm_campaign",
      "mtm_kwd", "relaunch"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "badge_badgeables", "badges", "diagnosis", "diagnosis_regions", "facility", "company", "feedbacks", "institution",
      "subject_answers", "landing", "landing_subject", "landing_theme", "matches", "needs", "subject", "theme", "visitee"
    ]
  end
end
