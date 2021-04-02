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

  # Inspiré de https://github.com/jumph4x/canonical-rails
  def canonical_tags
    canonical_url = raw "#{ENV['HOST_NAME']}#{path_without_html_extension}"
    capture do
      concat tag(:link, href: canonical_url, rel: :canonical)
      concat tag(:meta, property: 'og:url', content: canonical_url)
    end
  end

  def path_without_html_extension
    return '' if request.path == '/'
    request.path.sub(/\.html$/, '')
  end
end
