class CommunesController < ApplicationController
  skip_before_action :authenticate_user!

  def search
    query = params[:q].to_s.strip

    normalized_query = normalize_string(query)

    communes = communes_cache.select do |commune_data|
      commune_data[:normalized_nom].include?(normalized_query)
    end.first(20)

    render json: communes
  end

  private

  def communes_cache
    @communes_cache ||= Rails.cache.fetch('communes_autocomplete_v2', expires_in: 24.hours) do
      # Pre-load all departments at once to avoid N+1 queries
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
