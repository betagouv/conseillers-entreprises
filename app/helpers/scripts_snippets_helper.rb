module ScriptsSnippetsHelper
  def matomo_script
    if Rails.env.production?
      render partial: 'scripts_snippets/matomo'
    end
  end

  def sentry_script
    if Rails.env.production?
      render partial: 'scripts_snippets/sentry'
    end
  end
end
