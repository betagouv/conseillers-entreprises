# Monkey-patching for rswag Content-security policy.
# Cf https://github.com/betagouv/conseillers-entreprises/issues/4244
# Cf https://github.com/rswag/rswag/issues/744

module Extensions::CSP::Rswag
  def call(env)
    if base_path?(env)
      redirect_uri = env['SCRIPT_NAME'].chomp('/') + '/index.html'
      return [ 301, { 'Location' => redirect_uri }, [ ] ]
    end

    if index_path?(env)
      return [ 200, { 'Content-Type' => 'text/html', 'content-security-policy' => csp }, [ render_template ] ]
    end

    super
  end
end
