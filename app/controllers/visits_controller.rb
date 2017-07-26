# frozen_string_literal: true

class VisitsController < ApplicationController
  def show
    @visit = Visit.of_advisor(current_user).includes(%i[facility]).find params[:id]
    @facility = UseCases::SearchFacility.with_siret @visit.facility.siret
  end
end
