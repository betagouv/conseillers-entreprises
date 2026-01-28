class Api::Internal::CommunesSearch
  def initialize(query)
    @query = query.to_s.strip
  end

  def call
    normalized_query = normalize_string(@query)
    return [] if normalized_query.blank?

    communes_cache.select do |commune_data|
      commune_data[:normalized_nom].include?(normalized_query)
    end.first(20)
  end

  private

  def communes_cache
    Rails.cache.fetch('communes_autocomplete_v2', expires_in: 24.hours) do
      departements = DecoupageAdministratif::Departement.all.index_by(&:code)

      DecoupageAdministratif::Commune.all.map do |commune|
        departement = departements[commune.departement_code]
        {
          nom: commune.nom,
          code: commune.code,
          departement_code: commune.departement_code,
          departement_nom: departement.nom,
          normalized_nom: normalize_string(commune.nom)
        }
      end
    end
  end

  def normalize_string(str)
    I18n.transliterate(str)
      .downcase
      .gsub(/[^a-z0-9]+/, ' ')
      .strip
  end
end
