module StatusHelper
  STATUS_COLORS = {
    diagnosis_not_complete: %w[grey-blue],
    sent_to_no_one: %w[grey-blue],
    quo: %w[grey-blue],
    not_for_me: %w[red],
    taking_care: %w[green],
    done: %w[green],
    done_no_help: %w[orange],
    done_not_reachable: %w[blue-dark]
  }

  STATUS_ICONS = {
    diagnosis_not_complete: %w[],
    sent_to_no_one: %w[],
    quo: %w[ri-loader-2-line],
    not_for_me: %w[ri-close-line],
    taking_care: %w[ri-add-line],
    done: %w[ri-check-line],
    done_no_help: %w[icon ri-check-line],
    done_not_reachable: %w[icon ri-check-line]
  }

  EXPERTS_ICONS = {
    quo: %w[ri-user-received-line],
    not_for_me: %w[ri-user-unfollow-line],
    taking_care: %w[ri-user-add-line],
    done: %w[ri-user-follow-line],
    done_no_help: %w[ri-user-follow-line],
    done_not_reachable: %w[ri-user-follow-line],
    additional: %w[ri-user-search-line]
  }

  STATUS_CONTENT = %i[done done_no_help done_not_reachable]

  def match_actions_buttons(match)
    allowed_actions = match.allowed_new_status

    form_with(model: match, url: match_path(match)) do |f|
      allowed_actions.map do |new_status|
        title = Match.human_attribute_value(:status, new_status, context: :action)
        if STATUS_CONTENT.include?(new_status)
          content = { content: Match.human_attribute_value(:status, new_status, context: :content) }
        end
        classes = %w[ui small button match popup-hover] + STATUS_COLORS[new_status]
        f.button :submit, name: :status, value: new_status, class: classes.join(' '), data: (content if defined?(content)) do
          status_icon(new_status) + title
        end
      end.join.html_safe
    end
  end

  def admin_match_actions_buttons(match)
    allowed_actions = match.allowed_new_status

    form_with(model: match, url: match_path(match), class: 'menu') do |f|
      allowed_actions.map do |new_status|
        title = Match.human_attribute_value(:status, new_status, context: :action)
        classes = %w[gray-link] + EXPERTS_ICONS[new_status]
        f.button :submit, name: :status, value: new_status, class: classes.join(' ') do
          status_icon(:done) + title
        end
      end.join.html_safe
    end
  end

  def status_label(need_or_match, length = :short)
    status = need_or_match.status
    title = need_or_match.human_attribute_value(:status, context: length)
    classes = %w[label] + STATUS_COLORS[status.to_sym]
    tag.div(class: classes.join(' ')) do
      status_icon(status) + title
    end
  end

  def status_icon(status)
    classes = ['icon'] + STATUS_ICONS[status.to_sym]
    tag.i(class: classes.join(' '))
  end

  def expert_status_icon(match)
    classes = []
    classes << if match.additional_match?
      EXPERTS_ICONS[:additional]
    else
      EXPERTS_ICONS[match.status.to_sym]
    end
    classes << STATUS_COLORS[match.status.to_sym]
    tag.span('', class: classes.join(' '))
  end
end
