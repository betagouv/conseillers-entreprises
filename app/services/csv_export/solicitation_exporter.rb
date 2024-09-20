module CsvExport
  class SolicitationExporter < BaseExporter
    # Ici, il s'agit du big fichier qui présente l'historique des solicitations jusqu'aux fin d'histoire.
    # Il y a un donc un mélange de solicitations et de matchs
    def initialize(relation, options = {})
      solicitations_ids = relation.pluck(:id)
      @matches = Match.joins(diagnosis: :solicitation).where(solicitation: { id: solicitations_ids })

      @solicitations = relation.without_matches

      # Pour le nom du fichier
      @relation = @solicitations

      @options = options
    end

    def csv
      # /!\ les fields de MatchExporter et SolicitationExporter doivent correspondre pour garantir la cohérence du fichier
      matches_exporter = MatchExporter.new(@matches, @options)
      match_attributes = matches_exporter.fields
      solicitation_attributes = fields

      CSV.generate do |csv|
        csv << match_attributes.keys.map{ |attr| Match.human_attribute_name(attr, default: attr) }

        solicitation_row = solicitation_attributes.values
        sorted_solicitation_relation = sort_relation(@solicitations)
        while sorted_solicitation_relation.count > 0
          object = sorted_solicitation_relation.shift
          csv << solicitation_row.map do |val|
            if val.respond_to? :call
              lambda = val
              object.instance_exec(&lambda)
            else
              object.send(val)
            end
          end
        end

        match_row = match_attributes.values
        sorted_match_relation = matches_exporter.sort_relation(@matches)
        while sorted_match_relation.count > 0
          object = sorted_match_relation.shift
          csv << match_row.map do |val|
            if val.respond_to? :call
              lambda = val
              object.instance_exec(&lambda)
            else
              object.send(val)
            end
          end
        end
      end
    end

    def write_row(csv, row, object)
      csv << row.map do |val|
        if val.respond_to? :call
          lambda = val
          object.instance_exec(&lambda)
        else
          object.send(val)
        end
      end
    end

    def fields
      {
        solicitation_created_at: -> { I18n.l(created_at, format: :admin) },
        solicitation_id: -> { id },
        solicitation_description: -> { description },
        solicitation_provenance_category: -> { I18n.t(provenance_category, scope: %i(solicitation provenance_categories)) if provenance_category.present? },
        solicitation_provenance_title: -> { provenance_title },
        solicitation_provenance_detail: -> { provenance_detail },
        solicitation_origin_id: -> { origin_id },
        solicitation_gclid: -> { gclid },
        landing_theme_title: -> { landing_theme&.title },
        landing_subject_title: -> { subject&.label },
        siret: -> { siret },
        commune: -> { diagnosis&.facility&.commune },
        facility_regions: -> { region&.name },
        company_name: -> { diagnosis&.company&.name },
        company_categorie_juridique: -> { diagnosis&.company&.categorie_juridique },
        facility_naf: -> { diagnosis&.facility&.naf_code },
        facility_nafa: -> { diagnosis&.facility&.nafa_codes&.join(", ") },
        company_effectif: -> { Effectif::CodeEffectif.new(diagnosis&.facility&.displayable_code_effectif).intitule_effectif },
        company_forme_exercice: -> {  I18n.t(diagnosis&.company&.forme_exercice, scope: 'natures_entreprise', default: '') },
        facility_nature_activites: -> { diagnosis&.facility&.nature_activites&.map{ |nature| I18n.t(nature, scope: 'natures_entreprise') }&.join(', ') },
        inscrit_rcs: -> { I18n.t(diagnosis&.company&.inscrit_rcs, scope: [:boolean, :text], default: I18n.t('boolean.text.false')) },
        inscrit_rm: -> { I18n.t(diagnosis&.company&.inscrit_rm, scope: [:boolean, :text], default: I18n.t('boolean.text.false')) },
        activite_liberale: -> { I18n.t(diagnosis&.company&.activite_liberale, scope: [:boolean, :text], default: I18n.t('boolean.text.false')) },
        solicitation_full_name: -> { full_name },
        solicitation_email: -> { email },
        solicitation_phone_number: -> { phone_number },
        solicitation_badges: -> { badges.pluck(:title).join(', ') if badges&.any? },
        solicitation_status: -> { human_attribute_value(:status) },
      }
    end

    def preloaded_associations
      [
        :diagnosis, :facility, :badges, :landing_theme, :landing, :subject, diagnosis: :company, facility: :commune
      ]
    end

    def sort_relation(relation)
      relation.includes(*preloaded_associations).sort_by{ |m| m.created_at }
    end
  end
end
