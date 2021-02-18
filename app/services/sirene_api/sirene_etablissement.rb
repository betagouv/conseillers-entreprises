# frozen_string_literal: true

module SireneApi
  class SireneEtablissement
    attr_reader :siret, :nom, :enseigne, :activite, :lieu, :code_region

    def initialize(hash)
      @siret = hash[:siret]
      @nom = name_from_hash(hash)
      @enseigne = hash[:enseigne]
      @activite = hash[:libelle_activite_principale]
      @lieu = lieu_from_hash(hash)
      @code_region = hash[:region]
    end

    private

    def lieu_from_hash(hash)
      if hash[:code_postal].present? && hash[:libelle_commune].present?
        hash[:code_postal] + ' ' + hash[:libelle_commune]
      else
        hash[:libelle_region]
      end
    end

    def name_from_hash(hash)
      if hash[:nom].present? && hash[:prenom].present?
        hash[:nom] + ' ' + hash[:prenom]
      else
        hash[:nom_raison_sociale]
      end
    end
  end
end
