module ApplicationHelper
  def menu_link_with_count(title, count, url, options = {})
    active_link_to(url, options.merge(class: 'item')) do
      tag.div("#{count}", class: "ui label") + title
    end
  end
end
