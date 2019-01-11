module ContactHelper
  def all_needs_cards(f)
    localized_needs_keypath = 'contact.besoins.'
    all_needs = I18n.t(localized_needs_keypath)
    tags = all_needs.map do |value, text|
      needs_card_tag(f, value, text)
    end
    tags.join.html_safe
  end

  def needs_card_tag(f, value, text)
    tag.div class: 'card' do
      # f.radio_button('besoins', value) + f.label("besoins_#{value}", text)
      f.check_box("besoins[#{value}]") + f.label("besoins[#{value}]", text)
    end
  end

  def needs_description(message)
    needs_keys = message.besoins.select{ |_,v| v == 1 }.keys
    localized_needs = needs_keys.map{ |key| I18n.t("contact.besoins.#{key}") }
    tag.ul do
      localized_needs.map{ |need| tag.li(need) }.join.html_safe
    end
  end
end
