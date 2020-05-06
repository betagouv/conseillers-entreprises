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
  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_and_belongs_to_many :badges, -> { distinct }, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update

  ## Callbacks
  #
  def touch_after_badges_update(_badge)
    touch if persisted?
  end

  ## Validations
  #
  validates :landing_slug, :description, :full_name, :phone_number, :email, presence: true, allow_blank: false
  validates :email, format: { with: Devise.email_regexp }

  ## Scopes
  #
  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[partner_token pk_campaign pk_kwd gclid bg_color color branding]
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
