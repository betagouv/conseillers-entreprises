class Api::Internal::BaseController < ApplicationController
  skip_before_action :authenticate_user!
end
