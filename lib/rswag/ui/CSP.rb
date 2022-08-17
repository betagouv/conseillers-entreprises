module Rswag::Ui::CSP
  def call(env)
    _, headers, _ = response = super
    headers['Content-Security-Policy'] = <<~POLICY.tr "\n", ' '
      default-src 'self';
      img-src 'self' data: https://online.swagger.io;
      font-src 'self' https://fonts.gstatic.com;
      style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
      script-src 'self' 'unsafe-inline' 'unsafe-eval';
    POLICY
    response
  end
end

Rswag::Ui::Middleware.prepend Rswag::Ui::CSP
