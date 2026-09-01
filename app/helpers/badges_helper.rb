module BadgesHelper
  def badges_css_tag
    tag.style(nonce: content_security_policy_nonce) do
      Rails.cache.fetch(["badges-css", Badge.all]) do
        Badge.colored.map do |badge|
          ".badge--#{badge.long_name} { border: 1px solid #{badge.color}; color: #{badge.color} }"
        end.join(' ')
      end.html_safe
    end
  end

  def badge_label(badge)
    tag.div(badge.title, class: "label badge badge--#{badge.long_name}")
  end
end
