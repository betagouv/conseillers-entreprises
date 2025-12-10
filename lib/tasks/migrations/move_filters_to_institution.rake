namespace :migrations do
  desc 'Move specific match filters from Antenne/Expert to their Institution'
  task move_filters_to_institution: :environment do
    # Helper method to remove filters from both antennes and experts
    def remove_filters_from_filtrables(antennes, experts, filter_type, values, remove_filter_proc)
      all_filters = MatchFilter.where(filtrable_element: antennes)
        .or(MatchFilter.where(filtrable_element: experts))

      all_filters.find_each do |filter|
        remove_filter_proc.call(filter, filter_type, values)
      end
    end

    # Helper method to create or update array-based filter attribute
    def update_array_filter_attribute(filter, attribute_name, current_value, values_to_remove)
      return unless current_value.present? && current_value.intersect?(values_to_remove)

      filter.public_send("#{attribute_name}=", current_value - values_to_remove)
      filter.save!
      puts "Removed #{attribute_name} #{values_to_remove.join(', ')} from #{filter.filtrable_element_type} #{filter.filtrable_element_id}'s match_filters."
    end

    # Helper method to get or initialize institution filter
    def get_institution_filter(institution)
      institution.match_filters.find_or_initialize_by(filtrable_element: institution)
    end

    # rubocop:disable Metrics/CollectionLiteralLength
    institutions_to_process = [
      { name: "Chambre de Commerce et d'Industrie (CCI)", codes_to_remove: %w[6540] },
      { name: "Chambre des Métiers et de l'Artisanat (CMA)", codes_to_remove: %w[6540] },
      { name: "Initiative France", codes_to_remove: %w[6540 9210 9220 9230] },
      { name: "Banque de France", codes_to_remove: %w[1000], subject_id_for_transfer: 55 },
      {
        name: "Direction Régionale de l'Economie, de l'Emploi, du Travail et des Solidarités (DREETS)",
        subject_id_for_transfer: 42,
        effectif_min: 20,
        accepted_naf_codes: %w[
          0510Z 0520Z 0610Z 0620Z 0710Z 0721Z 0729Z 0811Z 0812Z 0891Z 0892Z 0893Z 0899Z 0910Z 0990Z 1011Z 1012Z 1013A
          1013B 1020Z 1031Z 1032Z 1039A 1039B 1041A 1041B 1042Z 1051A 1051B 1051C 1051D 1052Z 1061A 1061B 1062Z 1071A
          1071B 1071C 1071D 1072Z 1073Z 1081Z 1082Z 1083Z 1084Z 1085Z 1086Z 1089Z 1091Z 1092Z 1101Z 1102A 1102B 1103Z
          1104Z 1105Z 1106Z 1107A 1107B 1200Z 1310Z 1320Z 1330Z 1391Z 1392Z 1393Z 1394Z 1395Z 1396Z 1399Z 1411Z 1412Z
          1413Z 1414Z 1419Z 1420Z 1431Z 1439Z 1511Z 1512Z 1520Z 1610A 1610B 1621Z 1622Z 1623Z 1624Z 1629Z 1711Z 1712Z
          1721A 1721B 1721C 1722Z 1723Z 1724Z 1729Z 1811Z 1812Z 1813Z 1814Z 1820Z 1910Z 1920Z 2011Z 2012Z 2013A 2013B
          2014Z 2015Z 2016Z 2017Z 2020Z 2030Z 2041Z 2042Z 2051Z 2052Z 2053Z 2059Z 2060Z 2110Z 2120Z 2211Z 2219Z 2221Z
          2222Z 2223Z 2229A 2229B 2311Z 2312Z 2313Z 2314Z 2319Z 2320Z 2331Z 2332Z 2341Z 2342Z 2343Z 2344Z 2349Z 2351Z
          2352Z 2361Z 2362Z 2363Z 2364Z 2365Z 2369Z 2370Z 2391Z 2399Z 2410Z 2420Z 2431Z 2432Z 2433Z 2434Z 2441Z 2442Z
          2443Z 2444Z 2445Z 2446Z 2451Z 2452Z 2453Z 2454Z 2511Z 2512Z 2521Z 2529Z 2530Z 2540Z 2550A 2550B 2561Z 2562A
          2562B 2571Z 2572Z 2573A 2573B 2591Z 2592Z 2593Z 2594Z 2599A 2599B 2611Z 2612Z 2620Z 2630Z 2640Z 2651A 2651B
          2652Z 2660Z 2670Z 2680Z 2711Z 2712Z 2720Z 2731Z 2732Z 2733Z 2740Z 2751Z 2752Z 2790Z 2811Z 2812Z 2813Z 2814Z
          2815Z 2821Z 2822Z 2823Z 2824Z 2825Z 2829A 2829B 2830Z 2841Z 2849Z 2891Z 2892Z 2893Z 2894Z 2895Z 2896Z 2899A
          2899B 2910Z 2920Z 2931Z 2932Z 3011Z 3012Z 3020Z 3030Z 3040Z 3091Z 3092Z 3099Z 3101Z 3102Z 3103Z 3109A 3109B
          3211Z 3212Z 3213Z 3220Z 3230Z 3240Z 3250A 3250B 3291Z 3299Z 3311Z 3312Z 3313Z 3314Z 3315Z 3316Z 3317Z 3319Z
          3320A 3320B 3320C 3320D
        ].uniq
      }
    ]
    # rubocop:enable Metrics/CollectionLiteralLength

    institutions_to_process.each do |institution_data|
      institution_name = institution_data[:name]
      codes_to_remove = institution_data[:codes_to_remove]

      puts "Moving filters for codes #{(codes_to_remove || []).join(', ')} from #{institution_name} experts and antennes to #{institution_name} institution..."

      institution = Institution.find_by!(name: institution_name)

      experts = Expert.joins(antenne: :institution).where(institutions: { name: institution_name })
      antennes = Antenne.joins(:institution).where(institutions: { name: institution_name })

      ApplicationRecord.transaction do
        # Lambda to remove filters from a match_filter
        remove_filter = -> (match_filter, filter_type, values) {
          case filter_type
          when :excluded_legal_forms, :accepted_naf_codes
            attribute_name = filter_type
            current_value = match_filter.public_send(attribute_name)
            update_array_filter_attribute(match_filter, attribute_name, current_value, values)
          when :effectif_min
            if match_filter.effectif_min.present?
              match_filter.effectif_min = nil
              match_filter.save!
              puts "Removed effectif_min from #{match_filter.filtrable_element_type} #{match_filter.filtrable_element_id}'s match_filters."
            end
          when :subjects
            if match_filter.subjects.include?(values)
              match_filter.subjects.delete(values)
              match_filter.save!
              puts "Removed subject #{values.id} from #{match_filter.filtrable_element_type} #{match_filter.filtrable_element_id}'s match_filters."
            end
          end
        }

        # Handle excluded_legal_forms for institution
        if codes_to_remove.present?
          existing_institution_filter = institution.match_filters.find_by("excluded_legal_forms && ARRAY[?]::varchar[]", codes_to_remove)

          if existing_institution_filter
            new_codes = codes_to_remove - (existing_institution_filter.excluded_legal_forms || [])
            if new_codes.any?
              existing_institution_filter.excluded_legal_forms = (existing_institution_filter.excluded_legal_forms || []) + new_codes
              existing_institution_filter.save!
            end
          else
            institution.match_filters.create!(excluded_legal_forms: codes_to_remove)
          end

          remove_filters_from_filtrables(antennes, experts, :excluded_legal_forms, codes_to_remove, remove_filter)
        end

        # Handle effectif_min for institution
        if institution_data[:effectif_min].present?
          institution_filter = get_institution_filter(institution)
          institution_filter.effectif_min = institution_data[:effectif_min]
          institution_filter.save!
          puts "Added effectif_min #{institution_data[:effectif_min]} to Institution #{institution_name}'s match_filters."

          remove_filters_from_filtrables(antennes, experts, :effectif_min, nil, remove_filter)
        end

        # Handle accepted_naf_codes for institution
        if institution_data[:accepted_naf_codes].present?
          accepted_naf_codes = institution_data[:accepted_naf_codes]
          institution_filter = get_institution_filter(institution)

          new_naf_codes = accepted_naf_codes - (institution_filter.accepted_naf_codes || [])
          if new_naf_codes.any?
            institution_filter.accepted_naf_codes = (institution_filter.accepted_naf_codes || []) + new_naf_codes
            institution_filter.save!
            puts "Added accepted_naf_codes #{new_naf_codes.join(', ')} to Institution #{institution_name}'s match_filters."
          end

          remove_filters_from_filtrables(antennes, experts, :accepted_naf_codes, accepted_naf_codes, remove_filter)
        end

        # Handle subjects for institution
        if institution_data[:subject_id_for_transfer].present?
          subject_id = institution_data[:subject_id_for_transfer]
          subject = Subject.find(subject_id)

          institution_filter = get_institution_filter(institution)
          institution_filter.subjects << subject unless institution_filter.subjects.include?(subject)
          institution_filter.save!

          puts "Added subject #{subject_id} to Institution #{institution_name}'s match_filters."

          remove_filters_from_filtrables(antennes, experts, :subjects, subject, remove_filter)
        end

        # Remove empty filters - search for all filters that are now empty
        empty_filters = MatchFilter.where(filtrable_element: experts).or(MatchFilter.where(filtrable_element: antennes))
          .where("(accepted_naf_codes IS NULL OR accepted_naf_codes = '{}')")
          .where("(excluded_naf_codes IS NULL OR excluded_naf_codes = '{}')")
          .where("(accepted_legal_forms IS NULL OR accepted_legal_forms = '{}')")
          .where("(excluded_legal_forms IS NULL OR excluded_legal_forms = '{}')")
          .where(effectif_min: nil, effectif_max: nil, min_years_of_existence: nil, max_years_of_existence: nil)
          .left_joins(:subjects)
          .group('match_filters.id')
          .having('COUNT(subjects.id) = 0')

        empty_filters.each do |filter|
          puts "Destroying empty filter for #{filter.filtrable_element_type} #{filter.filtrable_element_id}."
          filter.destroy!
        end
      end

      puts "Done for #{institution_name}."
    end
  end
end
