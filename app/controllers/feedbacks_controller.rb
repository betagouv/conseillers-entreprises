class FeedbacksController < ApplicationController
  def create
    sanitized_params = sanitize_params feedback_params.merge(user: current_user)
    authorize Feedback.new(sanitized_params)
    @feedback = Feedback.create(sanitized_params)
    if @feedback.persisted?
      @feedback.notify_for_need!
    else
      flash.alert = @feedback.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end

    respond_to do |format|
      format.js
      format.html { redirect_to need_path(@feedback.need, anchor: "feedback-#{@feedback.id}") }
    end
  end

  def destroy
    feedback = retrieve_feedback
    return if feedback.nil?
    authorize feedback
    feedback.destroy!
    respond_to do |format|
      format.html { redirect_back fallback_location: reminders_expert_path }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("feedback-#{feedback.id}") }
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:description, :feedbackable_id, :feedbackable_type, :category)
  end

  def retrieve_feedback
    safe_params = params.permit(:id)
    Feedback.find_by(id: safe_params[:id])
  end
end
