module TerritoryFiltrable
  extend ActiveSupport::Concern

  def setup_territory_filters
    @territories = Territory.deployed_regions.order(:name)
    save_current_territory_filter
  end

  def find_current_territory
    @territory = Territory.find_by(id: territory_id)
  end

  private

  def save_current_territory_filter
    if territory_id.present?
      session[territory_session_param] = territory_id
    else
      session.delete(territory_session_param)
    end
  end

  def territory_id
    @territory_id = params.permit(:territory)[:territory] || session[territory_session_param]
  end

  # nom de variable surchargeable pour ne pas parasiter les autres filtres region
  def territory_session_param
    :territory
  end
end
