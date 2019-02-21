module SolicitationHelper
  def all_needs_cards(f)
    localized_needs_keypath = 'solicitations.needs.'
    all_needs = I18n.t(localized_needs_keypath)
    tags = all_needs.map do |value, text|
      needs_card_tag(f, value, text)
    end
    tags.join.html_safe
  end

  def needs_card_tag(f, value, text)
    tag.div class: 'card' do
      f.check_box("needs[#{value}]") + f.label("needs[#{value}]", text)
    end
  end

  def needs_description(solicitation)
    needs_keys = solicitation.needs.select{ |_,v| v == "1" }.keys.sort
    localized_needs = needs_keys.map{ |key| I18n.t("solicitations.needs.#{key}") }
    tag.ul do
      localized_needs.map{ |need| tag.li(need) }.join.html_safe
    end
  end
end
