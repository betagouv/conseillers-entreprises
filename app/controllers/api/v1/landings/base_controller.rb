class Api::V1::Landings::BaseController < Api::V1::BaseController
  require_api_key_scope ApiKey::LANDING_SUBJECTS

  private

  def retrieve_landing
    @landing = current_institution.landings.api.find(params.require(:landing_id))
  end
end
