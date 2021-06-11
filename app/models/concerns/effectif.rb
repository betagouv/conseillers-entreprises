module Effectif
  # https://www.sirene.fr/sirene/public/variable/tefen
  #
  extend ActiveSupport::Concern

  def effectif
    Effectif::effectif(self.code_effectif)
  end

  def self.effectif(code)
    if code.blank?
      return I18n.t('other')
    end

    I18n.t(code, scope: 'codes_effectif', default: I18n.t('other'))
  end

  UNITE_NON_EMPLOYEUSE = 'NN'

  def self.simple_effectif(code)
    I18n.t(code, scope: 'simple_effectif', default: I18n.t('other'))
  end
end
