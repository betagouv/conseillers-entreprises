module StatusHelper
  ##
  #
  def self.status_description(status, variant = '')
    namespace = 'attributes.statuses'
    case variant
    when :short
      namespace = 'attributes.statuses_short'
    when :action
      namespace = 'attributes.statuses_action'
    when nil
      namespace = 'attributes.statuses'
    end
    I18n.t(status, scope: namespace)
  end

  STATUS_COLORS = {
    diagnosis_not_complete: %w[lightgrey],
    sent_to_no_one: %w[lightgrey],
    quo: %w[lightgrey],
    not_for_me: %w[red],
    taking_care: %w[green],
    done: %w[green]
  }

  STATUS_ICONS = {
    diagnosis_not_complete: %w[],
    sent_to_no_one: %w[],
    quo: %w[],
    not_for_me: %w[icon remove],
    taking_care: %w[icon handshake outline],
    done: %w[icon checkmark]
  }

  def match_actions(match)
    allowed_actions = match.allowed_new_status

    form_with(model: match, url: match_path(match, access_token: params[:access_token])) do |f|
      allowed_actions.map do |new_status|
        title = StatusHelper::status_description(new_status, :action)
        classes = %w[ui small button] + STATUS_COLORS[new_status]
        f.button :submit, name: :status, value: new_status, class: classes.join(' ') do
          status_icon(new_status) + title
        end
      end.join.html_safe
    end
  end

  def status_label(status)
    status = status.to_sym
    title = StatusHelper::status_description(status, :short)
    classes = %w[ui label] + STATUS_COLORS[status]
    content_tag(:div, class: classes.join(' ')) do
      status_icon(status) + title
    end
  end

  def status_icon(status)
    classes = STATUS_ICONS[status.to_sym]
    tag.i(class: classes.join(' '))
  end

  module StatusDescription
    def status_description
      StatusHelper.status_description(status)
    end

    def status_short_description
      StatusHelper.status_description(status, :short)
    end
  end
end
