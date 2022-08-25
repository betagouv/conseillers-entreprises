module ApiSpecHelper
  def authentication_headers(organization = Organization.first)
    token = find_token(organization)
    @authentication_headers ||= { 'Authorization' => "Bearer token=#{token}" }
  end

  def find_token(organization = Organization.first)
    token = SecureRandom.hex(32)
    if organization.api_key.present?
      organization.api_key.update(token: token)
    else
      organization.create_api_key(token: token)
    end
    token
  end
end
