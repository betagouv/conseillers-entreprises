class RegionOrderingService
  # Service pour ordonner les régions françaises par nom
  # Prend les régions métropolitaines et les drom pour ne pas prendre les com
  def self.call
    metro = DecoupageAdministratif::Region.where(zone: "metro")
    drom = DecoupageAdministratif::Region.where(zone: "drom")
    (metro + drom).sort_by { |region| region.nom.downcase.tr('î', 'i') }
  end
end