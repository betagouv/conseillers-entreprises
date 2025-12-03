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

  # Format match filter attributes for display in ActiveAdmin
  # Returns a hash of { filter_name => formatted_content }
  def format_match_filter_attributes(match_filter)
    result = {}

    MatchFilter::FILTERS.each do |filter|
      case filter
      when :raw_accepted_naf_codes
        result[filter] = format_naf_codes(match_filter.accepted_naf_codes, match_filter.raw_accepted_naf_codes)
      when :raw_excluded_naf_codes
        result[filter] = format_naf_codes(match_filter.excluded_naf_codes, match_filter.raw_excluded_naf_codes)
      when :raw_accepted_legal_forms
        result[filter] = format_legal_forms(match_filter.accepted_legal_forms, match_filter.raw_accepted_legal_forms)
      when :raw_excluded_legal_forms
        result[filter] = format_legal_forms(match_filter.excluded_legal_forms, match_filter.raw_excluded_legal_forms)
      else
        result[filter] = match_filter.send(filter) if match_filter.send(filter).present?
      end
    end

    result.compact
  end

  private

  # Format NAF codes with labels if <= 10 codes, otherwise return raw string
  def format_naf_codes(codes, raw_codes)
    return nil if codes.blank?

    if codes.size > 10
      raw_codes
    else
      codes.map { |code| "#{code} - #{NafCode.naf_libelle(NafCode.level2_code(code), 'level2')}" }
        .join('<br>').html_safe
    end
  end

  # Format legal forms with descriptions if <= 10 codes, otherwise return raw string
  def format_legal_forms(codes, raw_codes)
    return nil if codes.blank?

    if codes.size > 10
      raw_codes
    else
      codes.map { |code| "#{code} - #{CategorieJuridique.description(code)}" }
        .join('<br>').html_safe
    end
  end
end
