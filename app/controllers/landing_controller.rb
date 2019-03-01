class LandingController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'empty'

  Landing = Struct.new(:title, :subtitle, :button, :url)

  def landing
    slug = params[:slug]&.to_sym
    redirect_to root_path if !landing_slugs.include?(slug)

    @landing = Landing.new(I18n.t("landing.#{slug}.title"),
      I18n.t("landing.#{slug}.subtitle"),
      I18n.t("landing.#{slug}.button"),
      url_to_root(slug))
  end

  private

  def landing_slugs
    landing_slugs_keypath = 'landing'
    I18n.t(landing_slugs_keypath).keys
  end

  def url_to_root(slug)
    tracking_params = { pk_source: 'landing', pk_campaign: 'entreprise', pk_content: slug }
    tracking_params.merge! existing_tracking_params
    root_path(tracking_params)
  end

  def existing_tracking_params
    params.permit(Solicitation::TRACKING_KEYS).to_h.symbolize_keys
  end
end
