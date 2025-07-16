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

        grouped_hash = Theme.joins(:subjects).where(subjects: { id: [base_needs.pluck(:subject_id)] }).each_with_object({}) do |theme, hash|
          hash[theme.label] = theme.present? ? calculate_needs_by_theme_size(theme) : nil
        end

        # Tri selon le nombre de besoins en ordre décroissant
        grouped_hash.sort_by { |_, count| -count }.each do |label, count|
          add_count_percentage_row(label, count, base_needs)
        end
        sheet.add_row
      end

      def by_subject_stats
        add_header_row('repartition.by_subject_header')

        grouped_hash = base_needs.pluck(:subject_id).tally

        grouped_hash.sort_by { |_, count| -count }.each do |subject_id, count|
          label = Subject.find(subject_id).label
          add_count_percentage_row(label, count, base_needs)
        end
        sheet.add_row
      end

      def by_region_stats
        add_header_row('repartition.by_region_header')

        grouped_hash = TerritorialZone.regions.each_with_object({}) do |region, hash|
          hash[region.nom] = base_needs.by_region(region.code).size
        end

        grouped_hash.sort_by { |_, count| -count }.each do |label, count|
          add_count_percentage_row(label, count, base_needs)
        end
        sheet.add_row
      end

      def by_effectif_stats
        add_header_row('repartition.by_effectif_header')
        codes_effectifs = base_companies
          .pluck(:code_effectif)
          .map{ |code| Effectif::CodeEffectif.new(code).stats_value }
        grouped_hash = codes_effectifs.tally

        grouped_hash.sort_by { |_, count| -count }.each do |code, count|
          label = Effectif::CodeEffectif.new(code).simple_effectif
          add_count_percentage_row(label, count, base_needs)
        end
        sheet.add_row
      end

      def by_naf_code_stats
        add_header_row('repartition.by_naf_code_header')

        grouped_hash = base_facilities.pluck(:naf_code_a10).tally

        grouped_hash.sort_by { |_, count| -count }.each do |code, count|
          label = NafCode.naf_libelle(code, 'a10')
          add_count_percentage_row(label, count, base_needs)
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
