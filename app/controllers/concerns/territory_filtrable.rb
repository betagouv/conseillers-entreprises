module TerritoryFiltrable
  extend ActiveSupport::Concern

  def retrieve_territory
    safe_params = params.permit(:territory)
    territory_id = safe_params[:territory] || session[:territory]
    if territory_id.present?
      session[:territory] = territory_id
      Territory.find(territory_id)
    else
      session.delete(:territory)
      nil
    end
  end

  def find_territories
    @territories = Territory.deployed_regions.order(:name)
    @territory = retrieve_territory
  end
end
