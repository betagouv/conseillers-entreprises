# == Schema Information
#
# Table name: api_keys
#
#  id             :bigint(8)        not null, primary key
#  token_digest   :string           not null
#  valid_until    :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)        not null
#
# Indexes
#
#  index_api_keys_on_institution_id  (institution_id)
#  index_api_keys_on_token_digest    (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#
class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = ENV.fetch('API_KEY_HMAC_SECRET_KEY', '0a1b2c3d')
  # Durée de vie max d'un token (recommandation ANSI, il me semble)
  LIFETIME = 18.months

  ## Associations
  #
  belongs_to :institution

  ## Scopes
  #
  scope :active, -> { where(arel_table[:valid_until].gt(Date.today)) }

  ## Callbacks
  #
  before_update :generate_token_hmac_digest
  before_update :calculate_valid_until

  # Virtual attribute for raw token value, allowing us to respond with the
  # API key's non-hashed token value. but only directly after creation.
  attr_accessor :token

  def self.authenticate_by_token!(token)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token
    find_by! token_digest: digest
  end

  def self.authenticate_by_token(token)
    authenticate_by_token! token
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def revoke
    self.update(valid_until: 1.day.ago)
  end

  def extend_lifetime
    self.update(valid_until: LIFETIME.since)
  end

  def active?
    self.valid_until > Date.today
  end

  def revoked_soon?
    self.valid_until < 2.months.since
  end

  private

  def generate_token_hmac_digest
    raise ActiveRecord::RecordInvalid, 'token is required' if token.blank?
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token
    self.token_digest = digest
  end

  def calculate_valid_until
    self.valid_until = LIFETIME.since
  end
end
