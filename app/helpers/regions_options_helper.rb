module RegionsOptionsHelper
  def regions_list
    I18n.t('regions_codes_to_libelles').sort_by{ |code, label| label }
  end
end
