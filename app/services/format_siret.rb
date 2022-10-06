# frozen_string_literal: true

class FormatSiret
  def self.siret_from_query(query)
    maybe_siret = clean_siret(query)
    maybe_siret if siret_is_valid(maybe_siret)
  end

  def self.siren_from_query(query)
    maybe_siren = clean_siret(query)
    maybe_siren if siren_is_valid(maybe_siren)
  end

  def self.clean_siret(maybe_siret)
    return if maybe_siret.blank?
    maybe_siret&.gsub(/[\W_]+/, '')
  end

  def self.siren_is_valid(siren)
    siren.present? && siren.match?(/^\d{9}$/) &&
    (luhn_valid(siren) || siret_is_hardcoded_valid(siren))
  end

  def self.siret_is_valid(siret)
    siret.present? && siret.match?(/^\d{14}$/) &&
      (luhn_valid(siret) || siret_is_hardcoded_valid(siret))
  end

  private

  def self.luhn_valid(str)
    s = str.reverse
    sum = 0
    (0..s.size - 1).step(2) do |k| # k is odd, k+1 is even
      sum += s[k].to_i # s1
      tmp = s[k + 1].to_i * 2
      if tmp > 9
        tmp = tmp.to_s.chars.sum(&:to_i)
      end
      sum += tmp
    end
    (sum % 10).zero?
  end

  def self.siret_is_hardcoded_valid(siret)
    # https://fr.wikipedia.org/wiki/Système_d%27identification_du_répertoire_des_établissements
    # Pour des raisons historiques, les SIRET attribués aux établissements du groupe La Poste utilisent une autre formule de validation, et ne sont donc pas tous valides au sens de la formule de Luhn. Le groupe La Poste ayant le SIREN : 356000000, les SIRET suivant cette autre formule de validation sont de la forme 356000000XXXXX
    siret.match?(/356000000...../)
  end
end
