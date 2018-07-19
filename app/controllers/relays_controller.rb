# frozen_string_literal: true

class RelaysController < ApplicationController
  def index
    @relays = current_user.relays.joins(:territory).order('territories.name')
    if @relays.count == 1
      redirect_to relay_path(@relays.first)
    end
  end

  def show
    @relay = Relay.find params[:id]
  end

  def diagnosis
    associations = [visit: [:visitee, :advisor, facility: [:company]],
                    diagnosed_needs: [matches: [assistance_expert: :expert]]
]
    @diagnosis = Diagnosis.includes(associations).find(params[:diagnosis_id])
    check_relay_access
    @current_user_diagnosed_needs = @diagnosis.needs_for(@relay)

    render 'experts/diagnosis'
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
