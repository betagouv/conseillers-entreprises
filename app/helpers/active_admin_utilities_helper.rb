# frozen_string_literal: true

module ActiveAdminUtilitiesHelper
  # Helpers pour ActiveAdmin
  def naf_a10_collection
    I18n.t('naf_libelle_a10').map{ |n| [n.last, n.first] }
  end

  def simple_effectif_collection
    # de façon incompréhensible, "1" n'est pas reconnu par ActiveAdmin pour ce select, d'où "01"
    %w[00 01 06 10 20 50 250].map do |code|
      [Effectif::CodeEffectif.new(code.to_i).simple_effectif, code]
    end
  end
end
