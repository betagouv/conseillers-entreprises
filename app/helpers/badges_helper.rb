# frozen_string_literal: true

module BadgesHelper
  def badge_label(badge)
    tag.div(badge.title, class: 'ui basic label badge',
                style: "border: 1px solid #{badge.color}; color: #{badge.color}")
  end

  def colored_label(content, color = '')
    tag.div(content, class: "ui label #{color}")
  end
end
