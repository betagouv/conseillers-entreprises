# frozen_string_literal: true

class TerritoryUserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/territory_user_mailer'

  def weekly_statistics(territory_user, information_hash, stats_csv)
    @user = territory_user.user
    @territory_name = territory_user.territory.name
    @information_hash = information_hash

    subject = t('mailers.territory_user_mailer.weekly_statistics.subject', territory_name: @territory_name)

    attach_csv_for_territory(stats_csv, @territory_name)
    mail(to: @user.email, subject: subject)
  end

  private

  def attach_csv_for_territory(stats_csv, territory_name)
    transliterated_territory_name = I18n.transliterate(territory_name).downcase
    date = Time.zone.today.iso8601
    file_name = "reso-#{transliterated_territory_name}-statistics-#{date}.csv"
    attachments[file_name] = { mime_type: 'text/csv', content: stats_csv }
  end
end
