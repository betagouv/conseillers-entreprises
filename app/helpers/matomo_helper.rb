module MatomoHelper
  def matomo_script
    if Rails.env.production?
      render partial: 'matomo/matomo'
    end
  end
end
