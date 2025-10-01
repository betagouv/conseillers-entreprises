class MatchesController < ApplicationController
  def update
    @match = Match.find(params[:id])
    authorize @match
    previous_status = @match.status
    @match.update status: params[:status]
    # Don't send emails when the current user is an administrator and therefore is not present in @match.contacted_users
    if @match.contacted_users.include?(current_user)
      MatchMailerService.new(@match).deduplicated_notify_status(previous_status)
    end
    respond_to do |format|
      format.js
      format.html { redirect_to need_path(@match.need, anchor: "match-#{@match.id}") }
    end
  end
end
