# frozen_string_literal: true

class TerritoryUserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/territory_user_mailer'

  def weekly_statistics(user, territory_name, information_hash)
    @user = user
    @territory_name = territory_name
    @information_hash = information_hash

    subject = t('mailers.territory_user_mailer.weekly_statistics.subject', territory_name: territory_name)
    mail(to: user.email, subject: subject)
  end
end
