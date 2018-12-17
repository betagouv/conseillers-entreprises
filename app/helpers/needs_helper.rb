# frozen_string_literal: true

module NeedsHelper
  def link_to_match_path(title, match, new_status, css_classes)
    classes = %w[ui button tiny] + css_classes
    token = params[:access_token]
    link_to title, match_path(match.id, access_token: token, status: new_status), data: { remote: true, method: :patch }, class: classes.join(' ')
  end
end
