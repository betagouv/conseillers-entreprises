# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :find_expert

  skip_before_action :authenticate_user!

  layout 'experts'

  def diagnosis
    associations = [visit: [:visitee, :advisor, facility: [:company]],
                    diagnosed_needs: [matches: [assistance_expert: :expert]]
]
    @diagnosis = Diagnosis.available_for_expert(@expert).includes(associations).find(params[:diagnosis_id])
    UseCases::UpdateExpertViewedPageAt.perform(diagnosis: @diagnosis, expert: @expert)
    @current_user_diagnosed_needs = @diagnosis.needs_for(@expert)
  end

  private

  def find_expert
    @expert = Expert.find_by! access_token: params[:access_token]
  end
end
