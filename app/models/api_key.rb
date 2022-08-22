# == Schema Information
#
# Table name: api_keys
#
#  id             :bigint(8)        not null, primary key
#  token_digest   :string           not null
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

  ## Associations
  #
  belongs_to :institution

  ## Callbacks
  #
  before_create :generate_token_hmac_digest

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

  private

  def generate_token_hmac_digest
    raise ActiveRecord::RecordInvalid, 'token is required' if token.blank?
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token
    self.token_digest = digest
  end
end
