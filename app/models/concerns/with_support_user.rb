module WithSupportUser
  extend ActiveSupport::Concern

  def support_user_name
    [support_user&.full_name, I18n.t('app_name')].compact.join(" - ")
  end

  def support_user_email_with_name
    email = support_user.present? ? support_user.email : ENV['APPLICATION_EMAIL']
    "#{support_user_name} <#{email}>"
  end
end
