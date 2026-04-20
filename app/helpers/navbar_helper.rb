module NavbarHelper
  def navbar_item(path, title, icon = nil, **options, &block)
    active_link_to(path, class: 'fr-nav__link', wrap_tag: :li, wrap_class: 'fr-nav__item', class_active: 'fr-nav__item--active', **options) do
      icon_tag = tag.span(class: class_names('fr-mr-1w', icon), 'aria-hidden': 'true') if icon
      additional_content = capture(&block) if block_given?
      [icon_tag, title, additional_content].join.html_safe
    end
  end
end
