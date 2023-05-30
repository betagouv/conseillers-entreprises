def authorize_insee_token
  ENV['INSEE_CONSUMER_KEY'] = 'consumer_key'
  ENV['INSEE_CONSUMER_TOKEN'] = 'consumer_token'
  insee_token = Base64.strict_encode64("consumer_key:consumer_token")
  stub_request(:post, 'https://api.insee.fr/token')
    .with(headers: { 'Authorization' => "Basic #{insee_token}" }, body: { grant_type: 'client_credentials' })
    .to_return(
      body: "{ 'token1234' }".to_json
    )
end

def authorize_rne_token
  ENV['RNE_USERNAME'] = 'rene nereux'
  ENV['RNE_PASSWORD'] = 'p4ssw0rd'
  stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
    .with(body: { username: 'rene nereux', password: 'p4ssw0rd' })
    .to_return(
      body: "{ 'token1234' }".to_json
    )
end
