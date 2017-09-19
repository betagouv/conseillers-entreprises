# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :find_expert

  skip_before_action :authenticate_user!

  layout 'experts'

  def diagnosis
    associations = [visit: [:visitee, :advisor, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.available_for_expert(@expert).includes(associations).find(params[:diagnosis_id])
    UseCases::UpdateExpertViewedPageAt.perform(diagnosis_id: params[:diagnosis_id].to_i, expert_id: @expert.id)
  end

  def take_care_of_need
    selected_assistance_expert = SelectedAssistanceExpert.of_expert(@expert).find params[:selected_assistance_expert_id]
    selected_assistance_expert.taking_care!
    render body: nil
  end

  private

  def find_expert
    @expert = Expert.find_by! access_token: params[:access_token]
  end
end
