class Conseiller::ExpertsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @experts = Expert
      .apply_filters(experts_params)
      .active
      .with_subjects
      .limit(20)
      .includes(:antenne, experts_subjects: :institution_subject)
    respond_to do |format|
      format.html
      format.json do
        render json: @experts, each_serializer: Autocomplete::ExpertSerializer
      end
    end
  end

  private

  def experts_params
    params.slice(:omnisearch).permit!
  end
end
