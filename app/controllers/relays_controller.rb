# frozen_string_literal: true

class RelaysController < ApplicationController
  def diagnoses
    @relay= Relay.of_user(current_user)
    @diagnoses = Diagnosis.joins(:diagnosed_needs)
                          .merge(DiagnosedNeed.of_relay(@relay))
                          .distinct
  end

  def diagnosis
    associations = [visit: [:visitee, :advisor, facility: [:company]],
                    diagnosed_needs: [matches: [assistance_expert: :expert]]]
    @diagnosis = Diagnosis.includes(associations).find(params[:diagnosis_id])
    check_relay_access
    @current_user_diagnosed_needs = @diagnosis.diagnosed_needs.of_relay(@relay)
                                              .includes(:matches)
    render 'experts/diagnosis'
  end

  def update_status
    relay = Relay.of_user(current_user)
    @match = Match.of_relay(relay)
                                                          .find params[:match_id]
    @match.update status: params[:status]
    render 'experts/update_status'
  end

  private

  def check_relay_access
    if current_user.is_admin? && params[:relay_id]
      @relay = Relay.find params[:relay_id]
    else
      @relay = Relay.of_user(current_user).of_diagnosis_location(@diagnosis).first
      if !@relay
        not_found
      end
    end
  end
end
