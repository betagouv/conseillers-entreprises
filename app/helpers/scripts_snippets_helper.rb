module ScriptsSnippetsHelper
  def matomo_script
    if Rails.env.production?
      render 'shared/matomo'
    end
  end

  def sentry_script
    if Rails.env.production?
      render 'shared/sentry'
    end
  end

  def tarteaucitron_script
    if Rails.env.production? && !in_iframe?
      render 'shared/tarteaucitron'
    end
  end

  def tarteaucitron_script_pages
    if Rails.env.production? && !in_iframe?
      render 'pages/tarteaucitron'
    end
  end

  def tarteaucitron_script_application
    if Rails.env.production?
      render 'application/tarteaucitron'
    end
  end
end
