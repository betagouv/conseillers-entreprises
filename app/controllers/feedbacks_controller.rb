class FeedbacksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  def create
    @feedback = Feedback.create(feedback_params)
    if @feedback.present?
      UserMailer.delay.match_feedback(@feedback)
    end
  end

  def destroy
    @feedback_id = params[:id]
    feedback = Feedback.find(@feedback_id)
    diagnosis = feedback.match.diagnosed_need.diagnosis

    check_current_user_access_to(feedback)

    feedback.destroy!
  end

  private

  def feedback_params
    params.require(:feedback).permit(:match_id, :description)
  end
end
