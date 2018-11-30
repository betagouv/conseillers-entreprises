# frozen_string_literal: true

module RelayService
  class MailerService
    class << self
      def send_relay_stats_emails
        relays = Relay.all.includes(territory: :communes)
        relays.each do |relay|
          send_relay_stats_email_to(relay)
        end
      end

      def send_relay_stats_email_to(relay)
        diagnoses = relay.territory_diagnoses

        information_hash = generate_statistics_hash diagnoses
        stats_csv = RelayService::CSVGenerator.generate_statistics_csv(diagnoses)

        RelayMailer.delay.weekly_statistics(relay, information_hash, stats_csv)
      end

      def generate_statistics_hash(territory_diagnoses)
        information_hash = RelayService::InformationHash.new

        created_diagnoses = territory_diagnoses.in_progress.created_last_week
        information_hash.fill_created_diagnoses_statistics created_diagnoses

        updated_diagnoses = territory_diagnoses.in_progress.created_before_last_week.updated_last_week
        information_hash.fill_updated_diagnoses_statistics updated_diagnoses

        completed_diagnoses = territory_diagnoses.completed.updated_last_week
        information_hash.fill_completed_diagnoses_statistics completed_diagnoses

        matches_count = Match.of_diagnoses(completed_diagnoses).count
        information_hash.fill_matches_count_statistics matches_count
        information_hash
      end
    end
  end
end
