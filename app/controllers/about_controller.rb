class AboutController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'solicitations'

  def show;
    @product_team = User.approved.project_team.ordered_for_contact.uniq
  end

  def cgu; end
end
