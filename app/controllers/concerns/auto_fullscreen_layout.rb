# frozen_string_literal: true

module AutoFullscreenLayout
  # Automatic support for fullscreen layout
  # This switches to the layout 'application_fullscreen' when `?fullscreen=true` is appended to the url
  # Otherwise, this respects the chosen layout of the controller.
  extend ActiveSupport::Concern

  included do
    prepend_before_action :detect_application_fullscreen

    # Implementation note: This means “use the layout returned by this method”,
    # not “use the layout named "application_fullscreen_layout"”.
    layout :application_fullscreen_layout

    attr_reader :application_fullscreen

    helper_method :application_fullscreen
  end

  def detect_application_fullscreen
    # Implementation note:
    # the hash returned by `params` is actually an instance variable of a superclass.
    # We’re modifying it early in the action process:
    # further calls to `params` return the modified hash, without the :fullscreen entry.
    # This is what we want; controller won’t complain about it being an umpermitted param.
    @application_fullscreen = params.delete(:fullscreen).to_b
  end

  def application_fullscreen_layout
    'application_fullscreen' if application_fullscreen
    # Implementation note: if not fullscreen, we return nil here.
    # This is what we want, and this is the behaviour documented for the `layout` method
    # to “Force default layout behavior with inheritance”.
  end
end
