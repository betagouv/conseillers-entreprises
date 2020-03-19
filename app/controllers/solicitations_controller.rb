class SolicitationsController < ApplicationController
  before_action :find_solicitation, only: [:show, :update_status]
  before_action :authorize_index_solicitation, only: [:index, :processed, :canceled]
  before_action :authorize_update_solicitation, only: [:update_status]

  def index
    @solicitations = ordered_solicitations.status_in_progress
  end

  def show
    authorize @solicitation
  end

  def processed
    @solicitations = ordered_solicitations.status_processed
  end

  def canceled
    @solicitations = ordered_solicitations.status_canceled
  end

  def update_status
    status = params[:status]
    @solicitation.update(status: status)
    done = Solicitation.human_attribute_name("statuses_done.#{status}", count: 1)
    flash.notice = "#{@solicitation} #{done}"
    render 'remove'
  end

  private

  def ordered_solicitations
    Solicitation.order(updated_at: :desc)
  end

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def authorize_update_solicitation
    authorize @solicitation, :update?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, :full_name, form_info: {}, needs: {})
  end
end
