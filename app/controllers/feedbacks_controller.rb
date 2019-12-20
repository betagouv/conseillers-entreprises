class FeedbacksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  def create
    @feedback = Feedback.create(feedback_params.merge(user: current_user, expert: current_expert))
    @current_roles = current_roles
    if @feedback.persisted?
      @feedback.notify!
    else
      flash.alert = @feedback.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    feedback = retrieve_feedback
    authorize feedback
    @feedback_id = feedback.id
    feedback.destroy!
  end

  private

  def feedback_params
    params.require(:feedback).permit(:need_id, :description)
  end

  def retrieve_feedback
    safe_params = params.permit(:id)
    Feedback.find(safe_params[:id])
  end
end
