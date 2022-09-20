module Effectif
  class CodeEffectif
    UNITE_NON_EMPLOYEUSE = 'NN'
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

    def initialize(code)
      @code = code
    end

    def intitule_effectif
      if @code.blank?
        return I18n.t('other')
      end

      I18n.t(@code, scope: 'codes_effectif', default: I18n.t('other'))
    end

    def simple_effectif
      I18n.t(@code, scope: 'simple_effectif', default: I18n.t('other'))
    end

    def range
      @range ||= RANGES.find{ |r| r[:code] == @code }
    end

    def max_bound
      return nil if range.nil?
      range[:max]
    end

    def min_bound
      return nil if range.nil?
      range[:min]
    end
  end
end
