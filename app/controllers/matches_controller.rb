class MatchesController < ApplicationController
  def update
    @match = Match.find(params.expect(:id))
    authorize @match
    previous_status = @match.status
    @match.update status: params[:status]
    # Don't send emails when the current user is an administrator and therefore is not present in @match.contacted_users
    if @match.contacted_users.include?(current_user)
      MatchMailerService.new(@match).deduplicated_notify_status(previous_status)
    end
    respond_to do |format|
      format.turbo_stream do
        stream = [turbo_stream.replace("row-match-#{@match.id}", partial: 'match', locals: { match: @match })]
        if current_user.experts.include?(@match.expert)
          stream << turbo_stream.replace('match-actions', partial: 'needs/match_actions', locals: { match: @match, display_feedback_form: true })
        end
        render turbo_stream: stream
      end
      format.html { redirect_to need_path(@match.need, anchor: "match-#{@match.id}") }
    end
  end
end
