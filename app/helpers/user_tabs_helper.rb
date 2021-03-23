# frozen_string_literal: true

module UserTabsHelper
  # Helper for the user_tabs layout.
  # If there are several tabs in the same section, add a section title;
  # If there is only one tab in the section, don’t add a section title.
  def experts_items_in_section(experts, path_component, section_title)
    if experts.size == 1
      expert = experts.first
      active_link_to section_title, polymorphic_path([path_component, expert]), { class: 'rf-sidemenu__link', wrap_tag: :li, wrap_class: 'rf-sidemenu__item', class_active: 'rf-sidemenu__item--active' }
    elsif experts.size > 1
      html = ''.html_safe
      html << tag.div(section_title, class: %w[ui sub header])
      experts.each do |expert|
        html << active_link_to(expert.full_name, polymorphic_path([path_component, expert]), { class: 'rf-sidemenu__link', wrap_tag: :li, wrap_class: 'rf-sidemenu__item', class_active: 'rf-sidemenu__item--active' })
      end
      html
    end
  end
end
