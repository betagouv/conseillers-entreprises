# frozen_string_literal: true

module AutoFullscreenLayout
  # Automatic support for fullscreen layout
  # This switches to the layout 'application_fullscreen' when `?fullscreen=true` is appended to the url
  # Otherwise, this respects the chosen layout of the controller.
  extend ActiveSupport::Concern

  included do
    prepend_before_action :detect_application_fullscreen
    layout :application_fullscreen_layout

    attr_reader :application_fullscreen

    helper_method :application_fullscreen
  end

  def detect_application_fullscreen
    @application_fullscreen = params.delete(:fullscreen).to_b
  end

  def application_fullscreen_layout
    'application_fullscreen' if application_fullscreen
  end
end
