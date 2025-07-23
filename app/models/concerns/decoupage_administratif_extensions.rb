# Extension temporaire pour DecoupageAdministratif
# À intégrer dans la gem plus tard
module DecoupageAdministratifExtensions
  extend ActiveSupport::Concern

  # Vérifier l'intersection entre territoires
  def territory_intersects_with_insee_codes?(insee_codes_array)
    return false if insee_codes_array.empty?
    
    case self.class.name.split('::').last
    when 'Commune'
      # Vérification si cette commune est dans la liste
      insee_codes_array.include?(self.code)
      
    when 'Departement'
      # Vérifie si au moins une commune du département est dans la liste
      # Optimisation: utilise les préfixes des codes INSEE
      departement_prefix = self.code.length == 2 ? self.code : self.code[0..1]
      insee_codes_array.any? { |code| code.start_with?(departement_prefix) }
      
    when 'Region' 
      # Vérifie via les départements de la région
      departement_codes = self.departements.map(&:code)
      insee_codes_array.any? do |insee_code|
        dept_code = insee_code.length >= 3 && insee_code[0..1].to_i >= 96 ? insee_code[0..2] : insee_code[0..1]
        departement_codes.include?(dept_code)
      end
      
    when 'Epci'
      # Utilise les codes des communes membres
      epci_commune_codes = self.membres.map { |membre| membre[:code] }
      (epci_commune_codes & insee_codes_array).any?
      
    else
      false
    end
  end

  # Méthode pour obtenir les codes INSEE d'un territoire
  def territory_insee_codes
    @territory_insee_codes ||= case self.class.name.split('::').last
    when 'Commune'
      [self.code]
    when 'Departement', 'Region'
      self.communes.map(&:code)
    when 'Epci'
      self.membres.map { |membre| membre[:code] }
    else
      []
    end
  end
end

# Extension des classes DecoupageAdministratif
[
  DecoupageAdministratif::Commune,
  DecoupageAdministratif::Departement, 
  DecoupageAdministratif::Region,
  DecoupageAdministratif::Epci
].each do |klass|
  klass.include DecoupageAdministratifExtensions
end