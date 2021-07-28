class LandingSubject< ApplicationRecord
  ## Associations
  #
  belongs_to :subject, inverse_of: :landing_subjects
  belongs_to :landing_theme, inverse_of: :landing_subjects
  has_many :solicitations, inverse_of: :landing_subject

  ## Validation
  #
  validates :slug, presence: true, uniqueness: true

  ## Scopes
  #
  scope :ordered_for_landing, -> { order(:position, :id) }

  def to_s
    slug
  end

  def to_param
    slug
  end

  REQUIRED_FIELDS_FLAGS = %i[
    requires_full_name
    requires_phone_number
    requires_email
    requires_siret
    requires_requested_help_amount
    requires_location
  ]
  REQUIRED_FIELDS_FLAGS.each do |flag|
    scope flag, -> { where(flag => true) }
    scope "not_#{flag}", -> { where(flag => false) }
  end

  def required_fields
    attributes.symbolize_keys
      .slice(*REQUIRED_FIELDS_FLAGS)
      .filter{ |_, value| value }
      .keys
      .map{ |flag| flag.to_s.delete_prefix('requires_').to_sym }
  end
end
