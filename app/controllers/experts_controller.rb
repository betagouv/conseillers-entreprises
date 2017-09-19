# frozen_string_literal: true

class ExpertsController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'experts'

  def diagnosis
    expert = Expert.find_by! access_token: params[:access_token]
    associations = [visit: [:visitee, :advisor, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.available_for_expert(expert).includes(associations).find(params[:diagnosis_id])
    UseCases::UpdateExpertViewedPageAt.perform(diagnosis_id: params[:diagnosis_id].to_i, expert_id: expert.id)
  end
end
