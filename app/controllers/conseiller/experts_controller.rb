class Conseiller::ExpertsController < ApplicationController
  before_action :authenticate_admin!

  def index
    retrieve_experts

    respond_to do |format|
      format.html
      format.json do
        render json: @experts, each_serializer: Autocomplete::ExpertSerializer
      end
    end
  end

  private

  def retrieve_experts
    base_query = Expert
      .apply_filters(experts_params)
      .active
      .with_subjects

    @experts = base_query
      .in_commune(params[:insee_code])
      .limit(10)
      .select("experts.*, 'primary' AS source")
      .load

    expert_with_code_size = @experts.size

    if expert_with_code_size < 10
      additional_experts = base_query
        .where.not(id: @experts.ids)
        .limit(10 - expert_with_code_size)
        .select("experts.*, 'secondary' AS source")
      @experts = @experts.to_a.concat(additional_experts.to_a)
    end
  end

  def experts_params
    params.slice(:omnisearch, :insee_code).permit!
  end
end
