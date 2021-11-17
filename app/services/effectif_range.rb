# frozen_string_literal: true

class EffectifRange
  RANGES = [
    { min: 0,     max: 0,     code: '00' },
    { min: 1,     max: 2,     code: '01' },
    { min: 3,     max: 5,     code: '02' },
    { min: 6,     max: 9,     code: '03' },
    { min: 10,    max: 19,    code: '11' },
    { min: 20,    max: 49,    code: '12' },
    { min: 50,    max: 99,    code: '21' },
    { min: 100,   max: 199,   code: '22' },
    { min: 200,   max: 249,   code: '31' },
    { min: 250,   max: 499,   code: '32' },
    { min: 500,   max: 999,   code: '41' },
    { min: 1000,  max: 1999,  code: '42' },
    { min: 2000,  max: 4999,  code: '51' },
    { min: 5000,  max: 9999,  code: '52' },
    { min: 10000, max: 99999, code: '53' },

  ]

  def initialize(params)
    @annee = params["annee"]
    @mois = params["mois"]  || '01'
    @effectifs = params["effectifs_mensuels"]&.to_f || params["effectifs_annuels"]&.to_f
  end

  def code_effectif
    @code_effectif ||= find_code_effectif
  end

  def intitule_effectif
    I18n.t(code_effectif, scope: 'codes_effectif', default: I18n.t('simple_effectif.Autre'))
  end

  def effectif
    @effectifs
  end

  def date_effectif
    return nil if code_effectif.blank?
    Date.parse("#{@annee}-#{@mois}-01")
  end

  private

  def find_code_effectif
    return nil if @effectifs.blank?
    code = nil
    RANGES.each do |range|
      if @effectifs >= range[:min] && @effectifs <= range[:max]
        code = range[:code]
        break
      end
    end
    code
  end
end
