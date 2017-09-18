# frozen_string_literal: true

class ExpertsController < ApplicationController
  skip_before_action :authenticate_user!

  def diagnosis
    associations = [visit: [:visitee, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.includes(associations).find params[:diagnosis_id]
  end
end
