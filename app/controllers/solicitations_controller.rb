class SolicitationsController < ApplicationController
  before_action :find_solicitation, only: [:show, :mark_as_processed, :mark_as_canceled, :mark_as_in_progress]
  before_action :authorize_index_solicitation, only: [:index, :processed, :canceled]
  before_action :authorize_update_solicitation, only: [:mark_as_processed, :mark_as_canceled, :mark_as_in_progress]

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

  def mark_as_processed
    @solicitation.status_processed!
    flash.notice = t('.done')
    render 'remove'
  end

  def mark_as_canceled
    @solicitation.status_canceled!
    flash.notice = t('.done')
    render 'remove'
  end

  def mark_as_in_progress
    @solicitation.status_in_progress!
    flash.notice = t('.done')
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

  def index_tracking_params
    params.permit(Solicitation::TRACKING_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, :full_name, form_info: {}, needs: {})
  end
end
