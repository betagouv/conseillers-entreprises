# frozen_string_literal: true

module UserTabsHelper
  # Helper for the user_tabs layout.
  # If there are several tabs in the same section, add a sublist;
  def experts_items_in_section(experts, path_component, section_title)
    if experts.size == 1
      expert = experts.first
      active_link_to section_title,
                     polymorphic_path([path_component, expert]),
                     { class: 'fr-sidemenu__link', wrap_tag: :li, wrap_class: 'fr-sidemenu__item', class_active: 'fr-sidemenu__item--active' }
    elsif experts.size > 1
      html = ''.html_safe
      html << content_tag(:div, class: "fr-sidemenu__btn") do
        section_title.pluralize.html_safe
      end
      list_items = experts.map do |expert|
        content_tag(:li, class: 'fr-sidemenu__item') do
          active_link_to(expert.full_name,
                         polymorphic_path([path_component, expert]),
                         { class: 'fr-sidemenu__link', wrap_tag: :li, wrap_class: 'fr-sidemenu__item', class_active: 'fr-sidemenu__item--active' }).html_safe
        end
      end.join.html_safe
      html << content_tag(:div) do
        content_tag(:ul, list_items, class: 'fr-sidemenu__list').html_safe
      end
      html
    end
  end
end
