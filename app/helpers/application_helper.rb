module ApplicationHelper
  def menu_link_with_count(title, count, url, options = {}, &block)
    if block
      options, url, count, title = url, count, title, capture(&block)
    end
    tag.li class: "fr-sidemenu__item item-with-tag #{options[:class]}" do
      active_link_to(url, options.deep_merge(class: 'fr-sidemenu__link', class_active: 'fr-sidemenu__item--active', data: { turbo: false })) do
       title
     end + tag.span("#{count}", class: "fr-tag fr-ml-2v", id: "counter-#{options[:name]}")
    end
  end

  # Inspiré de https://github.com/jumph4x/canonical-rails
  def canonical_tags
    capture do
      concat tag.link(href: canonical_url, rel: :canonical)
      concat tag.meta(property: 'og:url', content: canonical_url)
      concat tag.meta(property: 'og:image', content: image_url('logo-ce.png'))
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
    raw ENV['PRODUCTION_HOST_NAME']
  end

  def to_new_window_title(title)
    [title, t('to_new_window')].join(' - ')
  end

  def spam_trap_fields
    # Override the HoneypotGuard implementation
    # to localize the label and add the nonce in the style tag. See #4341.
    honeypot_html = content_tag(:div, class: "hp-field") do
      tag.style(".hp-field { display: none };", nonce: content_security_policy_nonce) +
        label_tag(HoneypotGuard.honeypot_field, t('honeypot_captcha.comment')) +
        text_field_tag(HoneypotGuard.honeypot_field, nil, autocomplete: "off")
    end

    timestamp_html = hidden_field_tag(HoneypotGuard.timestamp_field, Time.now.to_i)

    honeypot_html + timestamp_html
  end
end
