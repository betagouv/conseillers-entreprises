module BadgesHelper
  def badges_css_tag
    tag.style(nonce: content_security_policy_nonce) do
      Rails.cache.fetch(Badge.all) do
        Badge.colored.map do |badge|
          ".label--#{badge.long_name} { border: 1px solid #{badge.color}; color: #{badge.color} }"
        end.join(' ').html_safe
      end
    end
  end

  def badge_label(badge)
    tag.div(badge.title, class: "label label--#{badge.long_name}")
  end
end
