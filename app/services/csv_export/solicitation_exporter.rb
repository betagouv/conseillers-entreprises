module CsvExport
  class SolicitationExporter < BaseExporter
    # Ici, il s'agit du big fichier qui présente l'historique des solicitataions jusqu'aux fin d'histoire.
    # Il y a un donc un mélange de solicitations et de matchs
    def initialize(relation, options = {})
      matches_id = relation.preload(:matches).map{ |s| s.matches.pluck(:id) }.flatten
      @matches = Match.where(id: matches_id)
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
        csv << match_attributes.keys.map{ |attr| @matches.klass.human_attribute_name(attr, default: attr) }

        sort_relation(@solicitations).each do |object|
          row = solicitation_attributes.values
          write_row(csv, row, object)
        end

        matches_exporter.sort_relation(@matches).each do |object|
          row = match_attributes.values
          write_row(csv, row, object)
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
        solicitation_provenance_category: -> { I18n.t(provenance_category, scope: %i(solicitation provenance_categories)) if provenance_category&.present? },
        solicitation_provenance_title: -> { provenance_title },
        solicitation_provenance_detail: -> { provenance_detail },
        solicitation_gclid: -> { gclid },
        landing_theme_title: -> { landing_theme&.title },
        landing_subject_title: -> { landing_subject&.title },
        siret: -> { siret },
        commune: -> { diagnosis&.facility&.commune },
        facility_regions: -> { region&.name },
        company_name: -> { diagnosis&.company&.name },
        company_naf: -> { diagnosis&.facility&.naf_code },
        company_effectif: -> { Effectif.intitule_effectif(diagnosis&.facility&.code_effectif) },
        inscrit_rcs: -> { diagnosis&.company&.inscrit_rcs ? I18n.t('boolean.text.true') : I18n.t('boolean.text.false') },
        inscrit_rm: -> { diagnosis&.company&.inscrit_rm ? I18n.t('boolean.text.true') : I18n.t('boolean.text.false') },
        solicitation_full_name: -> { full_name },
        solicitation_email: -> { email },
        solicitation_phone_number: -> { phone_number },
        solicitation_badges: -> { badges.pluck(:title).join(', ') if badges&.any? },
        solicitation_status: -> { human_attribute_value(:status) },
      }
    end

    def preloaded_associations
      [
        :diagnosis, :facility, :badges, diagnosis: :company, facility: :commune
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by{ |m| m.created_at }
    end
  end
end
