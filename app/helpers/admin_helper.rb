module AdminHelper
  def status_tag_status_params(status)
    # Note: “status” is a property of Match and Need, but status_tag is also an ActiveAdmin helper
    css_class = { taking_care: 'warning', done: 'ok', not_for_me: 'error' }[status.to_sym]
    title = StatusHelper::status_description(status, :short)
    [title, class: css_class]
  end
end
