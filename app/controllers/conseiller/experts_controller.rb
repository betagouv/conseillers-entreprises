class Conseiller::ExpertsController < ApplicationController
  def index
    @experts = Expert
      .apply_filters(experts_params)
      .active
      .with_subjects
      .limit(20)
      .includes(:antenne, experts_subjects: :institution_subject)
    respond_to do |format|
      format.html do
      end
      format.json do
        render json: @experts.as_json
      end
    end

  end

  private

  def experts_params
    params.slice(:omnisearch).permit!
  end
end
