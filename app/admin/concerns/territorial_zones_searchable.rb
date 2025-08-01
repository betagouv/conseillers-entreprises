module TerritorialZonesSearchable
  extend ActiveSupport::Concern

  def search_territorial_zones
    query = params[:q][:nom_cont]

    communes = DecoupageAdministratif::Commune.where_ilike(nom: query).map do |zone|
      zone_hash(zone, 'commune')
    end

    epcis = DecoupageAdministratif::Epci.where_ilike(nom: query).map do |zone|
      zone_hash(zone, 'epci')
    end

    departements = DecoupageAdministratif::Departement.where_ilike(nom: query).map do |zone|
      zone_hash(zone, 'departement')
    end

    regions = DecoupageAdministratif::Region.where_ilike(nom: query).map do |zone|
      zone_hash(zone, 'region')
    end

    results = communes + epcis + departements + regions

    render json: results
  end

  private

  def zone_hash(zone, type)
    {
      id: zone.code,
      nom: "#{zone.nom} (#{zone.code})",
      type: type
    }
  end
end
