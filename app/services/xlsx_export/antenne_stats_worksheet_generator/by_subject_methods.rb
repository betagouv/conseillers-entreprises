module XlsxExport
  module AntenneStatsWorksheetGenerator
    module BySubjectMethods
      # Pages par sujet
      #
      def generate_by_subject_table(needs)
        cooperation_needs = needs.where(subject: Subject.from_external_cooperation)
        not_cooperation_needs = needs.where.not(id: cooperation_needs.ids)

        needs_by_subjects = {}
        antenne_subjects_labels = @antenne.institution.subjects.not_from_external_cooperation.pluck(:label)

        # /!\ Ici, pour des raisons de simplicité, on se base sur le sujet et non sur la solicitation pour trouver la coopération
        # Risque d'écarts avec les statistiques dynamiques
        not_cooperation_needs.map(&:subject).uniq.each do |subject|
          needs_by_subjects[subject.label] = not_cooperation_needs.where(subject: subject)
        end

        needs_by_antenne_subjects = needs_by_subjects.slice(*antenne_subjects_labels)
        needs_by_occasional_subjects = needs_by_subjects.except(*antenne_subjects_labels)

        generate_subjects_row(needs_by_antenne_subjects)

        # Sujets ponctuels
        if needs_by_occasional_subjects.any?
          sheet.add_row []
          add_subject_table_header(:occasional_subjects)
          generate_subjects_row(needs_by_occasional_subjects)
        end

        # Sujets coopération
        if cooperation_needs.any?
          cooperations = cooperation_needs.map(&:cooperation).uniq

          cooperations.each do |cooperation|
            sheet.add_row []
            add_subject_table_header(cooperation)
            needs_by_cooperation_subjects = cooperation_needs.by_cooperation(cooperation).map(&:subject).uniq.each_with_object({}) do |subject, hash|
              hash[subject.label] = cooperation_needs.where(subject: subject)
            end
            generate_subjects_row(needs_by_cooperation_subjects)
          end
        end

        finalise_agglomerate_style
      end

      def generate_subjects_row(needs_by_subjects, recipient = @antenne)
        needs_by_subjects.sort_by { |_, needs| -needs.count }.each do |subject_label, needs|
          ratio = calculate_rate(needs.count, current_needs)
          add_agglomerate_rows(needs, subject_label, recipient, ratio)
        end
      end

      def add_subject_table_header(key)
        sheet.add_row [
          build_first_tab(key),
          I18n.t('antenne_stats_exporter.needs_count'),
          I18n.t('antenne_stats_exporter.needs_percentage'),
          I18n.t('antenne_stats_exporter.positionning_rate'),
          I18n.t('antenne_stats_exporter.positionning_accepted_rate'),
          I18n.t('antenne_stats_exporter.done_rate')
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header]
      end

      def build_first_tab(key)
        if key.is_a?(Cooperation)
          I18n.t('antenne_stats_exporter.cooperation_subjects', cooperation: key.name)
        else
          I18n.t(key, scope: ['antenne_stats_exporter'])
        end
      end
    end
  end
end
