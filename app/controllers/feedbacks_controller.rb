class FeedbacksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  def create
    @feedback = Feedback.create(feedback_params)
    @current_roles = current_roles
    if @feedback.persisted?
      UserMailer.delay.match_feedback(@feedback)
    end
  end

  def destroy
    feedback = retrieve_feedback
    @feedback_id = feedback.id
    feedback.destroy!
  end

  private

  def feedback_params
    params.require(:feedback).permit(:match_id, :description)
  end

  def retrieve_feedback
    safe_params = params.permit(:id)
    feedback = Feedback.find(safe_params[:id])
    check_current_user_access_to(feedback, :write)
    feedback
  end
end
