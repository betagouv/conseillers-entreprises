def authorize_rne_token
  ENV['RNE_USERNAME'] = 'rene nereux'
  ENV['RNE_PASSWORD'] = 'p4ssw0rd'
  stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
    .with(body: { username: 'rene nereux', password: 'p4ssw0rd' })
    .to_return(
      body: "{ 'token1234' }".to_json
    )
end

def authorize_france_competence_token
  ENV['FRANCE_COMPETENCE_LOGIN'] = 'fc_login'
  ENV['FRANCE_COMPETENCE_PASSWORD'] = 'fc_password'
  ENV['FRANCE_COMPETENCE_AUTH_KEY'] = 'fc_auth_key'
  stub_request(:post, 'https://api.francecompetences.fr/siropartfc-auth/login')
    .with(
      body: { login: 'fc_login', password: 'fc_password' },
      headers: { 'X-Gravitee-Api-Key' => 'fc_auth_key' }
    )
    .to_return(
      body: "token1234"
    )
end

def stub_france_competence_siret(url, body, status_code = 200)
  ENV['FRANCE_COMPETENCE_SIRO_KEY'] = 'fc_siro_key'
  stub_request(:get, url)
    .with(headers: {
      'X-Gravitee-Api-Key' => 'fc_siro_key',
      'Authorization' => 'Bearer token1234'
    })
    .to_return(
      status: status_code,
      body: body
    )
end
