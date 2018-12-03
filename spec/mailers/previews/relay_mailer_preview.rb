class RelayMailerPreview < ActionMailer::Preview
  def weekly_statistics
    relay = Territory.find(29).relays.first

    diagnoses = relay.territory.diagnoses.order(created_at: :desc)
    information_hash = RelayService::MailerService::generate_statistics_hash diagnoses
    stats_csv = RelayService::CSVGenerator.generate_statistics_csv(diagnoses)
    RelayMailer.weekly_statistics(relay, information_hash, stats_csv)
  end
end
