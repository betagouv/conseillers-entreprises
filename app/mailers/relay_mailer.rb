# frozen_string_literal: true

class RelayMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/relay_mailer'

  def weekly_statistics(relay, information_hash, stats_csv)
    @user = relay.user
    @territory_name = relay.territory.name
    @information_hash = information_hash

    subject = t('mailers.relay_mailer.weekly_statistics.subject', territory_name: @territory_name)

    attach_csv_for_territory(stats_csv, @territory_name)
    mail(to: @user.email, subject: subject)
  end

  private

  def attach_csv_for_territory(stats_csv, territory_name)
    transliterated_territory_name = I18n.transliterate(territory_name).downcase
    date = Time.zone.today.iso8601
    file_name = "place-des-entreprises-#{transliterated_territory_name}-statistics-#{date}.csv"
    attachments[file_name] = { mime_type: 'text/csv', content: stats_csv }
  end
end
