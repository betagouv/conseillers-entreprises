# frozen_string_literal: true

module RelayService
  class MailerService
    class << self
      def send_statistics_email
        relays = Relay.all.includes(territory: :territory_cities)
        relays.each do |relay|
          send_statistics_email_to relay
        end
      end

      private

      def send_statistics_email_to(user)
        associations = [visit: [:advisor, facility: [:company]],
                        diagnosed_needs: %i[question selected_assistance_experts]]
        not_admin_territory_diagnoses = Diagnosis.includes(associations)
                                                 .of_user(User.not_admin)
                                                 .in_territory(user.territory)
                                                 .reverse_chronological

        information_hash = generate_statistics_hash not_admin_territory_diagnoses
        stats_csv = RelayService::CSVGenerator.generate_statistics_csv(not_admin_territory_diagnoses)

        RelayMailer.delay.weekly_statistics(user, information_hash, stats_csv)
      end

      def generate_statistics_hash(territory_diagnoses)
        information_hash = RelayService::InformationHash.new

        created_diagnoses = territory_diagnoses.in_progress.created_last_week
        information_hash.fill_created_diagnoses_statistics created_diagnoses

        updated_diagnoses = territory_diagnoses.in_progress.created_before_last_week.updated_last_week
        information_hash.fill_updated_diagnoses_statistics updated_diagnoses

        completed_diagnoses = territory_diagnoses.completed.updated_last_week
        information_hash.fill_completed_diagnoses_statistics completed_diagnoses

        contacted_experts_count = SelectedAssistanceExpert.of_diagnoses(completed_diagnoses).count
        information_hash.fill_contacted_experts_count_statistics contacted_experts_count
        information_hash
      end
    end
  end
end
