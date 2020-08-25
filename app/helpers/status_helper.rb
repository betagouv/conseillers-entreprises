module StatusHelper
  STATUS_COLORS = {
    diagnosis_not_complete: %w[grey],
    sent_to_no_one: %w[grey],
    quo: %w[grey],
    not_for_me: %w[red],
    taking_care: %w[green],
    done: %w[green],
    done_no_help: %w[yellow],
    done_not_reachable: %w[teal]
  }

  STATUS_ICONS = {
    diagnosis_not_complete: %w[],
    sent_to_no_one: %w[],
    quo: %w[],
    not_for_me: %w[icon remove],
    taking_care: %w[icon handshake outline],
    done: %w[icon checkmark],
    done_no_help: %w[icon checkmark],
    done_not_reachable: %w[icon checkmark]
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
    if match.allowed_new_status.include? :done
      form_with(model: match, url: match_path(match)) do |f|
        title = Match.human_attribute_value(:status, :done, context: :action)
        classes = %w[ui small button] + STATUS_COLORS[:done]
        f.button :submit, name: :status, value: :done, class: classes.join(' ') do
          status_icon(:done) + title
        end
      end
    end
  end

  def status_label(need_or_match)
    status = need_or_match.status
    title = need_or_match.human_attribute_value(:status, context: :short)
    classes = %w[ui basic label] + STATUS_COLORS[status.to_sym]
    tag.div(class: classes.join(' ')) do
      status_icon(status) + title
    end
  end

  def status_icon(status)
    classes = STATUS_ICONS[status.to_sym]
    tag.i(class: classes.join(' '))
  end
end
