# frozen_string_literal: true

module ActiveAdminUtilitiesHelper
  # Helpers pour ActiveAdmin
  def naf_a10_collection
    I18n.t('naf_libelle_a10').map{ |n| [n.last, n.first] }
  end

  def simple_effectif_collection
    Effectif::Helpers.simple_effectif_collection
  end
end
