module ApplicationHelper
  def menu_link_with_count(title, count, url, options = {}, &block)
    if block
      options, url, count, title = url, count, title, capture(&block)
    end
    tag.li class: 'rf-sidemenu__item item-with-tag' do
      active_link_to(url, options.merge(class: 'rf-sidemenu__link', class_active: 'rf-sidemenu__item--active')) do
       title
     end + tag.span("#{count}", class: "rf-tag rf-ml-2v")
    end
  end
end
