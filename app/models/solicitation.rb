# == Schema Information
#
# Table name: solicitations
#
#  id           :bigint(8)        not null, primary key
#  description  :string
#  email        :string
#  form_info    :jsonb
#  full_name    :string
#  options      :jsonb
#  phone_number :string
#  siret        :string
#  slug         :string
#  status       :integer          default("in_progress")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_solicitations_on_slug  (slug)
#

class Solicitation < ApplicationRecord
  enum status: { in_progress: 0, processed: 1, canceled: 2 }, _prefix: true

  ## Associations
  #
  has_many :diagnoses, inverse_of: :solicitation
  belongs_to :landing, primary_key: :slug, foreign_key: :slug, inverse_of: :solicitations, optional: true
  has_and_belongs_to_many :badges, -> { distinct }

  ## Validations
  #
  validates :slug, :description, :full_name, :phone_number, :email, presence: true, allow_blank: false
  validate :validate_selected_options
  validates :email, format: { with: Devise.email_regexp }


  ## Scopes
  #
  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }
  scope :with_selected_option, -> (option) { where("options->>? = '1'", option) }

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[partner_token pk_campaign pk_kwd gclid]
  store_accessor :form_info, FORM_INFO_KEYS.map(&:to_s)

  ## ActiveAdmin/Ransacker helpers
  #
  FORM_INFO_KEYS.each do |key|
    ransacker key do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:form_info], Arel::Nodes.build_quoted(key.to_s))
    end
  end
  ransacker(:with_selected_option, formatter: -> (value) {
    with_selected_option(value).pluck(:id)
      .presence
  }) { |parent| parent.table[:id] }

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

  ##
  #
  def institution
    Institution.find_by(partner_token: partner_token) if partner_token.present?
  end

  def selected_options
    options.select{ |_, v| v.to_bool }.keys
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

  ## Validations
  #
  def validate_selected_options
    if landing&.landing_options.present? && selected_options.empty?
      errors.add(:options, :blank)
    end
  end
end
