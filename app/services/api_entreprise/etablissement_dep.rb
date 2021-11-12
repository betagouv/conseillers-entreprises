# frozen_string_literal: true

module ApiEntreprise
  class EtablissementDep < OpenStruct
    def readable_locality
      code_postal = dig('adresse', 'code_postal')
      localite = dig('adresse', 'localite')
      [code_postal, localite].reject(&:blank?).join(' ').presence
    end
  end
end
