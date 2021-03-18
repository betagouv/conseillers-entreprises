class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.create(feedback_params.merge(user: current_user))
    if @feedback.persisted?
      @feedback.notify_for_need!
    else
      flash.alert = @feedback.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end

    respond_to do |format|
      format.js
      format.html { redirect_to diagnosis_path(@feedback.need.diagnosis, anchor: "feedback-#{@feedback.id}") }
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
    params.require(:feedback).permit(:description, :feedbackable_id, :feedbackable_type, :category)
  end

  def retrieve_feedback
    safe_params = params.permit(:id)
    Feedback.find(safe_params[:id])
  end
end
