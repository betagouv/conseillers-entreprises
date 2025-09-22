module Admin
  module Helpers
    module InterventionZoneDescription
      def intervention_zone_description(many_communes)
        summary = many_communes.intervention_zone_summary

        descriptions = summary[:territories].map do |hash|
          territory = hash[:territory]
          link = link_to(territory, admin_territory_path(territory))
          description = "#{link} : #{hash[:included]} / #{territory.communes.count}"

          if hash[:included] < territory.communes.count
            params = many_communes.is_a?(Antenne) ? { antenne: many_communes } : { expert: many_communes }
            confirm_message = I18n.t('active_admin.territory.confirm_assign_entire_territory', territory: territory, many_communes: many_communes)
            use_entire_territory_link = link_to(
              I18n.t('active_admin.territory.assign_entire_territory'),
              assign_entire_territory_admin_territory_path(territory, params),
              method: :post,
              data: { confirm: confirm_message }
            )
            description = "#{description} — #{use_entire_territory_link}"
          end

          description.html_safe
        end

        other = summary[:other]
        if other > 0
          descriptions << "#{I18n.t('other')} : #{other}"
        end

        descriptions.join("<br/>").html_safe
      end

      def displays_insee_codes(antenne_communes)
        communes_grouped = antenne_communes.order(:insee_code).group_by do |x|
          # Prend 2 chiffres pour la métropole et 3 pour les outres-mer
          x.insee_code.to_i >= 97000 ? x.insee_code[0..2] : x.insee_code[0..1]
        end
        list = ""
        communes_grouped.map do |department_code, communes|
          department_name = I18n.t(department_code, scope: 'department_codes_to_libelles')
          build_list(list, department_code, department_name, communes)
        end
        list.html_safe
      end

      def build_list(list, department_code, department_name, communes)
        list << tag.h3(I18n.t('active_admin.territory.department_number', number: department_code, name: department_name))
        list << tag.i(I18n.t('active_admin.territory.communes_size', count: communes.size))
        list << tag.div("#{communes.pluck(:insee_code).flatten.join(' ')}")
        list
      end
    end

    Arbre::Element.include InterventionZoneDescription
  end
end
