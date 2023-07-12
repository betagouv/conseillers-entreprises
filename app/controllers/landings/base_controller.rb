class Landings::BaseController < PagesController
  include IframePrefix
  before_action :fill_query_params
end
