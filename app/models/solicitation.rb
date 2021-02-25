# == Schema Information
#
# Table name: solicitations
#
#  id                               :bigint(8)        not null, primary key
#  code_region                      :integer
#  description                      :string
#  email                            :string
#  form_info                        :jsonb
#  full_name                        :string
#  landing_options_slugs            :string           is an Array
#  landing_slug                     :string           not null
#  location                         :string
#  phone_number                     :string
#  prepare_diagnosis_errors_details :jsonb
#  requested_help_amount            :string
#  siret                            :string
#  status                           :integer          default("in_progress")
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  institution_id                   :bigint(8)
#
# Indexes
#
#  index_solicitations_on_code_region     (code_region)
#  index_solicitations_on_email           (email)
#  index_solicitations_on_institution_id  (institution_id)
#  index_solicitations_on_landing_slug    (landing_slug)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#

class Solicitation < ApplicationRecord
  include DiagnosisCreation::SolicitationMethods
  include RangeScopes

  enum status: { in_progress: 0, processed: 1, canceled: 2 }, _prefix: true

  ## Associations
  #
  belongs_to :landing, primary_key: :slug, foreign_key: :landing_slug, inverse_of: :solicitations, optional: true
  has_one :diagnosis, inverse_of: :solicitation
  has_many :diagnosis_regions, -> { regions }, through: :diagnosis, source: :facility_territories, inverse_of: :diagnoses

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
  validates :landing_slug, :description, presence: true, allow_blank: false
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

  scope :with_feedbacks, -> do
    status_in_progress
      .joins(:feedbacks)
  end

  scope :without_feedbacks, -> do
    status_in_progress
      .left_outer_joins(:feedbacks)
      .where(feedbacks: { id: nil })
  end

  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }

  scope :by_territory, -> (territory) do
    joins(:diagnosis).where(diagnoses: { facility: territory&.facilities })
  end

  scope :by_territories, -> (territories) do
    joins(:diagnosis).where(diagnoses: { facility: territories.map{ |t| t.facility_ids }.flatten })
  end

  scope :in_regions, -> (codes_regions) do
    where(code_region: codes_regions)
  end

  scope :out_of_regions, -> (codes_regions) do
    where.not(code_region: codes_regions).where.not(code_region: nil)
  end

  scope :in_unknown_region, -> { where(code_region: nil) }

  # param peut être un id de Territory ou une clé correspondant à un scope ("without_diagnosis" par ex)
  scope :by_possible_territory, -> (param) {
    begin
      by_territory(Territory.find(param))
    rescue ActiveRecord::RecordNotFound => e
      self.send(param)
    end
  }

  # Pour détecter les pb de siret, par exemple
  scope :without_diagnosis, -> {
    left_outer_joins(:diagnosis)
      .where(diagnoses: { id: nil })
  }

  scope :out_of_deployed_territories, -> {
    joins(:diagnosis).merge(Diagnosis.out_of_deployed_territories)
  }

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[pk_campaign pk_kwd gclid institution]
  FORM_INFO_KEYS_WITH_ACCESSORS = %i[pk_campaign pk_kwd gclid] # We want :institution as a form_info parameter, but we don’t want accessors for it that would conflict with the belongs_to relation.
  store_accessor :form_info, FORM_INFO_KEYS_WITH_ACCESSORS.map(&:to_s)

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
  DEFAULT_REQUIRED_FIELDS = %i[full_name phone_number email siret]

  def required_fields
    landing_option&.required_fields || DEFAULT_REQUIRED_FIELDS
  end

  FIELD_TYPES = {
    full_name: 'text',
    phone_number: 'tel',
    email: 'email',
    siret: 'text',
    requested_help_amount: 'text',
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
end
