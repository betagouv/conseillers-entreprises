class Landings::BaseController < PagesController
  include IframePrefix

  private

  def save_query_params
    (query_params.presence)
  end
end
