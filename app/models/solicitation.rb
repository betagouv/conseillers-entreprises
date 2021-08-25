# == Schema Information
#
# Table name: solicitations
#
#  id                               :bigint(8)        not null, primary key
#  code_region                      :integer
#  created_in_deployed_region       :boolean          default(FALSE)
#  description                      :string
#  email                            :string
#  form_info                        :jsonb
#  full_name                        :string
#  landing_options_slugs            :string           is an Array
#  landing_slug                     :string
#  location                         :string
#  phone_number                     :string
#  prepare_diagnosis_errors_details :jsonb
#  requested_help_amount            :string
#  siret                            :string
#  status                           :integer          default("in_progress")
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
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#  fk_rails_...  (landing_id => landings.id)
#  fk_rails_...  (landing_subject_id => landing_subjects.id)
#

class Solicitation < ApplicationRecord
  include DiagnosisCreation::SolicitationMethods
  include RangeScopes

  enum status: { in_progress: 0, processed: 1, canceled: 2, reminded: 3 }, _prefix: true

  ## Associations
  #
  # belongs_to :landing, primary_key: :slug, foreign_key: :landing_slug, inverse_of: :solicitations, optional: true
  belongs_to :landing, inverse_of: :solicitations, optional: true
  belongs_to :landing_subject, inverse_of: :solicitations, optional: true
  has_one :landing_theme, through: :landing_subject, source: :landing_theme, inverse_of: :landing_subjects

  has_one :diagnosis, inverse_of: :solicitation
  has_many :diagnosis_regions, -> { regions }, through: :diagnosis, source: :facility_territories, inverse_of: :diagnoses
  has_one :facility, through: :diagnosis, source: :facility, inverse_of: :diagnoses

  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :matches, through: :diagnosis, inverse_of: :solicitation
  has_many :needs, through: :diagnosis, inverse_of: :solicitation
  has_and_belongs_to_many :badges, -> { distinct }, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update
  belongs_to :institution, inverse_of: :solicitations, optional: true

  before_create :set_institution_from_landing

  ## Callbacks
  #
  def set_institution_from_landing
    self.institution ||= landing&.institution || Institution.find_by(slug: form_info&.fetch('institution', nil))
  end

  def touch_after_badges_update(_badge)
    touch if persisted?
  end

  ## Validations
  #
  validates :landing, :description, presence: true, allow_blank: false
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validate on: :create do
    # All visible fields are required on creation
    required_fields.each do |attr|
      errors.add(attr, :blank) if self.public_send(attr).blank?
    end
  end

  ## Scopes
  #
  scope :omnisearch, -> (query) do
    if query.present?
      where(id: have_badge(query))
        .or(have_landing_option(query))
        .or(description_contains(query))
        .or(have_landing(query))
        .or(name_contains(query))
        .or(email_contains(query))
        .or(pk_kwd_contains(query))
        .or(pk_campaign_contains(query))
    end
  end

  scope :have_badge, -> (query) do
    joins(:badges).where('badges.title ILIKE ?', "%#{query}%")
  end

  scope :have_landing_option, -> (query) do
    where('? = ANY(solicitations.landing_options_slugs)', query)
  end

  scope :have_landing, -> (query) do
    where('solicitations.landing_slug ILIKE ?', "%#{query}%")
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

  scope :pk_kwd_contains, -> (query) {
    where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}%")
  }

  scope :pk_campaign_contains, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}%")
  }

  scope :without_diagnosis, -> {
    left_outer_joins(:diagnosis)
      .where(diagnoses: { id: nil })
  }

  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }

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

  # param peut être un id de Territory ou une clé correspondant à un scope ("uncategorisable" par ex)
  scope :by_possible_region, -> (param) {
    begin
      in_regions(Territory.find(param).code_region)
    rescue ActiveRecord::RecordNotFound => e
      self.send(param)
    end
  }

  # scope destiné à recevoir les solicitations qui ne sortent pas
  # dans les autres filtres des solicitation.
  # La méthode d'identification pourra evoluer au fil du temps
  scope :uncategorisable, -> {
    in_unknown_region
  }

  scope :out_of_deployed_territories, -> {
    out_of_regions(Territory.deployed_codes_regions)
  }

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[pk_campaign pk_kwd gclid]
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

  ## Options
  # I would love to use a has_many relation, but Rails doesn’t (yet?) support backing relations with postgresql arrays.
  def landing_options=(landing_options)
    self.landing_options_slugs = landing_options.pluck(:slug)
  end

  def landing_options
    LandingOption.where(slug: landing_options_slugs)
  end

  def landing_option
    # Technically, a solicitation can have many landing_options; however, we currently limit it to 1 in the UI.
    landing_options&.first
  end

  ## Visible fields in form
  #
  # Used \when a solicitation is made without a landing_option
  BASE_REQUIRED_FIELDS = %i[full_name phone_number email]
  DEFAULT_REQUIRED_FIELDS = %i[full_name phone_number email siret]

  def required_fields
    if landing_subject.present?
      BASE_REQUIRED_FIELDS + landing_subject&.required_fields
    else
      DEFAULT_REQUIRED_FIELDS
    end
  end

  FIELD_TYPES = {
    full_name: 'text',
    phone_number: 'tel',
    email: 'email',
    siret: 'text',
    location: 'text'
  }

  ## Preselection
  #
  def preselected_subjects
    landing_options.map(&:preselected_subject).compact
  end

  def preselected_institutions
    landing_options.map(&:preselected_institution).compact
  end

  # * Retrieve all the landing options slugs used in the past;
  #   LandingOptions may have been removed, but the slug remains here.
  # * :landing_options_slugs is a postgresql array; we could use unnest() to flatten it
  #   but let’s keep it easier to understand. It’s not performance-critical.
  def self.all_past_landing_options_slugs
    self.pluck(:landing_options_slugs).flatten.uniq
  end

  def normalized_phone_number
    number = phone_number&.gsub(/[^0-9]/,'')
    if number.present? && number.length == 10
      number.gsub(/(.{2})(?=.)/, '\1 \2')
    else
      phone_number
    end
  end

  def to_s
    "#{self.class.model_name.human} #{id}"
  end

  def display_attributes
    %i[normalized_phone_number institution requested_help_amount location pk_campaign pk_kwd]
  end

  def normalized_siret
    siret.gsub(/(\d{3})(\d{3})(\d{3})(\d*)/, '\1 \2 \3 \4')
  end

  ##
  #
  def allowed_new_statuses
    self.class.statuses.keys - [self.status]
  end

  def transmitted_at
    diagnosis&.completed_at
  end

  def region
    Territory.find_by(code_region: self.code_region)
  end
end
