# frozen_string_literal: true

class CommunesController < ApplicationController
  def find_cities
    @cities = ApiAdresse::Query.cities_of_postcode(params[:postal_code])
    render json: @cities
  end
end
