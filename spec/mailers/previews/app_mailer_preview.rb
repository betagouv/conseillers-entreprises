class AppMailerPreview < ActionMailer::Preview
  # until this issue is resolved by rails team
  # https://github.com/rails/rails/pull/33483
  require "rails/application_controller"
  class Rails::MailersController < Rails::ApplicationController
    content_security_policy(false)
  end
end
