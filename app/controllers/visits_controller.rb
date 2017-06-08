# frozen_string_literal: true

class VisitsController < ApplicationController
  def new
    @visit = Visit.new siret: params[:siret]
  end

  def create
    @visit = Visit.new visit_param
    @visit.advisor = current_user
    if @visit.save
      redirect_to company_path(siret: @visit.siret)
    else
      render 'new'
    end
  end

  private

  def visit_param
    params.require(:visit).permit(:siret, :happened_at)
  end
end
