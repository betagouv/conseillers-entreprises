class FeedbacksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  def create
    feedback = Feedback.create!(feedback_params)
    diagnosis = feedback.match.diagnosed_need.diagnosis

    UserMailer.delay.match_feedback(feedback)

    redirect_back fallback_location: besoin_path(diagnosis, params.permit(:access_token))
  end

  def destroy
    feedback = Feedback.find(params[:id])
    diagnosis = feedback.match.diagnosed_need.diagnosis

    check_current_user_access_to(feedback)

    feedback.destroy!

    redirect_back fallback_location: besoin_path(diagnosis, params.permit(:access_token))
  end

  private

  def feedback_params
    params.require(:feedback).permit(:match_id, :description)
  end
end
