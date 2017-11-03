# frozen_string_literal: true

class TerritoryUsersController < ApplicationController
  def diagnoses
    @territory_user = TerritoryUser.of_user(current_user)
    @diagnoses = Diagnosis.joins(:diagnosed_needs).merge(DiagnosedNeed.of_territory_user(@territory_user)).distinct
  end

  def diagnosis
    associations = [visit: [:visitee, :advisor, facility: [:company]],
                    diagnosed_needs: [selected_assistance_experts: [assistance_expert: :expert]]]
    @diagnosis = Diagnosis.unscoped.includes(associations).find(params[:diagnosis_id])
    check_territory_user_access
    @current_user_diagnosed_needs = @diagnosis.diagnosed_needs.of_territory_user(@territory_user)
                                              .includes(:selected_assistance_experts)
    render 'experts/diagnosis'
  end

  def update_status
    territory_user = TerritoryUser.of_user(current_user)
    @selected_assistance_expert = SelectedAssistanceExpert.of_territory_user(territory_user)
                                                          .find params[:selected_assistance_expert_id]
    @selected_assistance_expert.update status: params[:status]
    render 'experts/update_status'
  end

  private

  def check_territory_user_access
    if current_user.is_admin? && params[:territory_user_id]
      @territory_user = TerritoryUser.find params[:territory_user_id]
    else
      @territory_user = TerritoryUser.of_user(current_user).of_diagnosis_location(@diagnosis).first
      not_found unless @territory_user
    end
  end
end
