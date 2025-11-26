namespace :migrations do
  desc 'Move specific match filters from Antenne/Expert to their Institution'
  task move_filters_to_institution: :environment do
    institutions_to_process = [
      { name: "Chambre de Commerce et d'Industrie (CCI)", codes_to_remove: ["6540"] },
      { name: "Chambre des Métiers et de l'Artisanat (CMA)", codes_to_remove: ["6540"] },
      { name: "Initiative France", codes_to_remove: ["6540", "9210", "9220", "9230"] },
      { name: "Banque de France", codes_to_remove: ["1000"], subject_id_for_transfer: 55 }
    ]

    institutions_to_process.each do |institution_data|
      institution_name = institution_data[:name]
      codes_to_remove = institution_data[:codes_to_remove]

      puts "Moving filters for codes #{codes_to_remove.join(', ')} from #{institution_name} experts and antennes to #{institution_name} institution..."

      institution = Institution.find_by!(name: institution_name)

      experts = Expert.joins(antenne: :institution).where(institutions: { name: institution_name })
      antennes = Antenne.joins(:institution).where(institutions: { name: institution_name })

      expert_filters = MatchFilter.where(filtrable_element: experts)
      antenne_filters = MatchFilter.where(filtrable_element: antennes)

      all_filters = expert_filters.or(antenne_filters)

      ApplicationRecord.transaction do
        # Consolidate codes for the institution's filter
        if codes_to_remove.present?
          existing_institution_filter = institution.match_filters.find_by("excluded_legal_forms && ARRAY[?]::varchar[]", codes_to_remove)

          if existing_institution_filter
            # Add only missing codes to the existing filter
            new_codes = codes_to_remove - (existing_institution_filter.excluded_legal_forms || []) # Ensure it's an array
            if new_codes.any?
              existing_institution_filter.excluded_legal_forms = (existing_institution_filter.excluded_legal_forms || []) + new_codes
              existing_institution_filter.save!
            end
          else
            # Create a new filter with all codes
            institution.match_filters.create!(excluded_legal_forms: codes_to_remove)
          end

          # Remove codes_to_remove from antenne filters
          antennes.each do |antenne|
            antenne.match_filters.each do |filter|
              if filter.excluded_legal_forms.present? && filter.excluded_legal_forms.intersect?(codes_to_remove)
                filter.excluded_legal_forms = filter.excluded_legal_forms - codes_to_remove
                filter.save!
                puts "Removed codes_to_remove #{codes_to_remove.join(', ')} from Antenne #{antenne.id}'s match_filters."
              end
            end
          end
        end

        # Remove empty filters
        all_filters.each do |filter|
          if filter.filter_types.empty?
            filter.destroy!
          end
        end

        # Handle accepted_legal_forms for institution and subjects for antennes
        if institution_data[:subject_id_for_transfer].present?
          subject_id = institution_data[:subject_id_for_transfer]
          subject = Subject.find(subject_id)

          institution_filter = institution.match_filters.find_or_initialize_by(
            filtrable_element: institution
          )
          institution_filter.subjects << subject unless institution_filter.subjects.include?(subject)
          institution_filter.save!

          puts "Added subject #{subject_id} to Institution #{institution_name}'s match_filters."
        end

        if institution_data[:subject_id_for_transfer].present?
          subject_id = institution_data[:subject_id_for_transfer]
          subject = Subject.find(subject_id)

          antennes.each do |antenne|
            antenne.match_filters.each do |filter|
              if filter.subjects.include?(subject)
                filter.subjects.delete(subject)
                filter.save!
                puts "Removed subject #{subject_id} from Antenne #{antenne.id}'s match_filters."
              end
            end
          end
        end
      end

      puts "Done for #{institution_name}."
    end
  end
end
