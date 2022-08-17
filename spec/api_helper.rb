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
