module XlsxExport
  module CooperationWorksheetGenerator
    class Repartition < Base
      def generate
        sheet.add_row
        by_theme_stats
        by_subject_stats
        by_region_stats
        by_effectif_stats
        by_naf_code_stats

        finalise_style
      end

      private

      def by_theme_stats
        add_header_row('repartition.by_theme_header')

        needs_by_theme = {}
        Theme.joins(:subjects).merge(base_subjects).each do |theme|
          needs_by_theme[theme.label] = theme.present? ? calculate_needs_by_theme_size(theme) : nil
        end

        # Tri selon le nombre de besoins en ordre décroissant
        needs_by_theme.sort_by { |_, needs_count| -needs_count }.each do |label, needs_count|
          add_count_percentage_row(label, needs_count, base_needs)
        end
        sheet.add_row
      end

      def by_subject_stats
        add_header_row('repartition.by_subject_header')

        needs_by_subject = {}
        base_subjects.each do |subject|
          needs_by_subject[subject.label] = subject.present? ? base_needs.where(subject: subject).size : nil
        end

        needs_by_subject.sort_by { |_, needs_count| -needs_count }.each do |label, needs_count|
          add_count_percentage_row(label, needs_count, base_needs)
        end
        sheet.add_row
      end

      def by_region_stats
        add_header_row('repartition.by_region_header')

        needs_by_region = {}
        Territory.regions.each do |region|
          needs_by_region[region.name] = base_needs.by_region(region.id).size
        end

        needs_by_region.sort_by { |_, needs_count| -needs_count }.each do |label, needs_count|
          add_count_percentage_row(label, needs_count, base_needs)
        end
        sheet.add_row
      end

      def by_effectif_stats
        add_header_row('repartition.by_effectif_header')

        codes_effectifs = base_companies.pluck(:code_effectif).compact_blank.uniq
        temporary_result = codes_effectifs.index_with do |code_effectif|
          base_companies.where(code_effectif: code_effectif).size
        end
        # On intègre les code_effectif nil
        temporary_result["NN"] ||= 0
        temporary_result["NN"] += base_companies.where(code_effectif: nil).size

        companies_by_effectif = {}
        temporary_result.each do |key, value|
          new_code = I18n.t(key, scope: 'code_to_range', default: I18n.t('00', scope: 'code_to_range')).to_s
          companies_by_effectif[new_code] ||= 0
          companies_by_effectif[new_code] += value
        end

        companies_by_effectif.sort_by { |_, count| -count }.each do |label, count|
          text_label = Effectif::CodeEffectif.new(label).simple_effectif
          add_count_percentage_row(text_label, count, base_companies)
        end
        sheet.add_row
      end

      def by_naf_code_stats
        add_header_row('repartition.by_naf_code_header')

        naf_codes = base_facilities.uniq.pluck(:naf_code_a10)
        grouped = naf_codes.tally

        grouped.sort_by { |_, needs_count| -needs_count }.each do |code, needs_count|
          label = NafCode.naf_libelle(code, 'a10')
          add_count_percentage_row(label, needs_count, base_needs)
        end
        sheet.add_row
      end

      def finalise_style
        [
          'A1:C1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 15, 15
      end

      ## Base data
      #
      def base_subjects
        @subjects ||= Subject.where(id: [base_needs.pluck(:subject_id)])
      end

      def base_companies
        @companies ||= Company
          .includes(diagnoses: :solicitation).references(diagnoses: :solicitation)
          .where(facilities: { diagnoses: { step: :completed, created_at: @start_date..@end_date } })
          .where(solicitation: { cooperation_id: @cooperation.id })
      end

      def base_facilities
        @facilities ||= Facility
          .includes(diagnoses: :solicitation).references(diagnoses: :solicitation)
          .where(diagnoses: { step: :completed, created_at: @start_date..@end_date })
          .where(solicitation: { cooperation_id: @cooperation.id })
      end
    end
  end
end
