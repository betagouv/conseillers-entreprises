module MatchHelper
  STATUS_COLORS = {
    quo: %w[lightgrey],
    not_for_me: %w[red],
    taking_care: %w[green],
    done: %w[green]
  }

  STATUS_ICONS = {
    quo: %w[],
    not_for_me: %w[icon remove],
    taking_care: %w[icon handshake outline],
    done: %w[icon checkmark]
  }

  def match_actions(match)
    allowed_actions = match.allowed_new_status

    links = allowed_actions.map do |new_status|
      title = I18n.t("activerecord.attributes.match.statuses_action.#{new_status}")
      path = match_path(match.id, status: new_status, access_token: params[:access_token])
      classes = %w[ui small button] + STATUS_COLORS[new_status]
      link_to path, data: { remote: true, method: :patch }, class: classes.join(' ') do
        status_icon(new_status) + title
      end
    end
    links.join.html_safe
  end

  def match_status_label(status)
    status = status.to_sym
    title = I18n.t("activerecord.attributes.match.statuses_short.#{status}")
    classes = %w[ui label] + STATUS_COLORS[status]
    content_tag(:div, class: classes.join(' ')) do
      status_icon(status) + title
    end
  end

  def status_icon(status)
    classes = STATUS_ICONS[status.to_sym]
    tag.i(class: classes.join(' '))
  end
end
