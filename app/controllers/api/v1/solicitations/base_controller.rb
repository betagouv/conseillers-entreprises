class Api::V1::Solicitations::BaseController < Api::V1::BaseController
  before_action :authorize_qualification_scope!

  private

  def authorize_qualification_scope!
    return if current_api_key&.has_scope?(ApiKey::QUALIFICATION)

    errors = [{ source: I18n.t('api_pde.errors.forbidden.source'), message: I18n.t('api_pde.errors.forbidden.message') }]
    render_error_payload(errors: errors, status: :forbidden)
  end
end
