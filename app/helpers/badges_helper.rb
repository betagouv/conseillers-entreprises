# frozen_string_literal: true

module BadgesHelper
  def badge_label(badge)
    tag.div(badge.title, class: 'label',
                style: "border: 1px solid #{badge.color}; color: #{badge.color}")
  end

  def expert_positionning_rate_tag(expert)
    # Pour avoir un pourcentage de positionnement, et non de non positionnement
    rate = 100 - (PositionningRate::Member.new(expert).rate.round(2) * 100)
    tag.div("#{rate.to_i} %", class: 'fr-tag')
  end
end
