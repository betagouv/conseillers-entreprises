module ApplicationHelper
  def menu_link_with_count(title, count, url, options = {}, &block)
    if block
      options, url, count, title = url, count, title, capture(&block)
    end
    tag.li class: 'fr-sidemenu__item item-with-tag' do
      active_link_to(url, options.merge(class: 'fr-sidemenu__link', class_active: 'fr-sidemenu__item--active')) do
       title
     end + tag.span("#{count}", class: "fr-tag fr-ml-2v")
    end
  end

  # Inspiré de https://github.com/jumph4x/canonical-rails
  def canonical_tags
    capture do
      concat tag.link(href: canonical_url, rel: :canonical)
      concat tag.meta(property: 'og:url', content: canonical_url)
    end
  end

  def path_without_html_extension
    return '' if request.path == '/'
    request.path.sub(/\.html$/, '')
  end

  def canonical_url
    @canonical_url ||= "#{canonical_base_url}#{path_without_html_extension}"
  end

  def canonical_base_url
    raw ENV['HOST_NAME']
  end
end
