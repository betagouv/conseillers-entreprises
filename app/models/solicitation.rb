# == Schema Information
#
# Table name: solicitations
#
#  id                    :bigint(8)        not null, primary key
#  description           :string
#  email                 :string
#  form_info             :jsonb
#  full_name             :string
#  landing_options_slugs :string           is an Array
#  landing_slug          :string           not null
#  options_deprecated    :jsonb
#  phone_number          :string
#  siret                 :string
#  status                :integer          default("in_progress")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_solicitations_on_landing_slug  (landing_slug)
#

class Solicitation < ApplicationRecord
  enum status: { in_progress: 0, processed: 1, canceled: 2 }, _prefix: true

  ## Associations
  #
  belongs_to :landing, primary_key: :slug, foreign_key: :landing_slug, inverse_of: :solicitations, optional: true
  has_many :diagnoses, inverse_of: :solicitation
  has_and_belongs_to_many :badges, -> { distinct }

  ## Validations
  #
  validates :landing_slug, :description, :full_name, :phone_number, :email, presence: true, allow_blank: false
  validate :validate_landing_options_on_create, on: :create
  validates :email, format: { with: Devise.email_regexp }

  def validate_landing_options_on_create
    # if the landing has options, landing_options should refer to existing options on creation
    # later, landing_options_slugs may refer to removed LandingOptions
    if landing&.landing_options.present? && landing_options.empty?
      errors.add(:landing_options, :blank)
    end
  end

  ## Scopes
  #
  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[partner_token pk_campaign pk_kwd gclid]
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

  def options=(options_hash) # Support for old-style solicitation form. TODO: Remove this
    self.landing_options_slugs = options_hash.select{ |_, v| v.to_bool }.keys
  end

  ##
  #
  def institution
    Institution.find_by(partner_token: partner_token) if partner_token.present?
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
    %i[normalized_phone_number institution pk_campaign pk_kwd]
  end

  def normalized_siret
    siret.gsub(/(\d{3})(\d{3})(\d{3})(\d*)/, '\1 \2 \3 \4')
  end

  ##
  #
  def allowed_new_statuses
    self.class.statuses.keys - [self.status]
  end
end
