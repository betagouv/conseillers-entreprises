# frozen_string_literal: true

class NeedsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  after_action :mark_expert_viewed, only: :show

  def index
    @relays = relays
    @experts = experts
  end

  def show
    associations = [
      :visitee, :advisor, facility: [:company],
      diagnosed_needs: [matches: [expert_skill: :expert]]
    ]
    @diagnosis = Diagnosis.includes(associations).find(params[:id])

    check_current_user_access_to(@diagnosis)
    @current_roles = current_roles
  end

  private

  def relays
    current_user.present? ? current_user.relays.joins(:territory).order('territories.name')
      : []
  end

  def experts
    current_user.present? ? current_user.experts.order(:full_name)
      : [current_expert]
  end

  def mark_expert_viewed
    experts.each do |expert|
      UseCases::UpdateExpertViewedPageAt.perform(diagnosis: params[:id].to_i, expert: expert)
    end
  end
end
