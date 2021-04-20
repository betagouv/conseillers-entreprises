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
    if Rails.env.production?
      render 'shared/tarteaucitron'
    end
  end
end
