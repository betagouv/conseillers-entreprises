require 'benchmark'

module CsvExport
  class SolicitationExporter < BaseExporter
    # Ici, il s'agit du big fichier qui présente l'historique des solicitations jusqu'aux fin d'histoire.
    # Il y a un donc un mélange de solicitations et de matchs
    def initialize(relation, options = {})
      puts 'YOLOOOOOOOOOOOOOOOO ---------------------------'
      ActiveRecord::Base.logger.silence do
        time = Benchmark.measure do
          # time_matches_old = Benchmark.measure do
          #   matches_id = relation.preload(:matches).map{ |s| s.matches.pluck(:id) }.flatten
          #   @matches = Match.where(id: matches_id)
          # puts "------ time_matches old : #{time_matches_old}"

          time_matches_new = Benchmark.measure do
            solicitations_ids = relation.pluck(:id)
            @matches = Match
                        .joins(diagnosis: :solicitation)
                        .where(solicitation: { id: solicitations_ids })
          end
          puts "------ time_matches NEW : #{time_matches_new}"

          time_solicitations = Benchmark.measure do
            @solicitations = relation.without_matches
          end
          puts "------ time_solicitations : #{time_solicitations}"
          # Pour le nom du fichier
          @relation = @solicitations

          @options = options
        end
        puts "SolicitationExporter::initialize time : #{time}"
      end
    end

    def csv
      all_csv = nil
      time = Benchmark.measure do
        # /!\ les fields de MatchExporter et SolicitationExporter doivent correspondre pour garantir la cohérence du fichier
        matches_exporter = MatchExporter.new(@matches, @options)
        match_attributes = matches_exporter.fields
        solicitation_attributes = fields

        all_csv = CSV.generate do |csv|
          csv << match_attributes.keys.map{ |attr| Match.human_attribute_name(attr, default: attr) }

          time_solicitations = Benchmark.measure do
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
          end
          puts "----- generate csv with solicitations time : #{time_solicitations}"

          time_matches = Benchmark.measure do
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
          puts "----- generate csv with matches time : #{time_matches}"
        end

      end
      puts "SolicitationExporter::csv time : #{time}"
      all_csv
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
        solicitation_gclid: -> { gclid },
        landing_theme_title: -> { landing_theme&.title },
        landing_subject_title: -> { subject&.label },
        siret: -> { siret },
        commune: -> { diagnosis&.facility&.commune },
        facility_regions: -> { region&.name },
        company_name: -> { diagnosis&.company&.name },
        company_categorie_juridique: -> { diagnosis&.company&.categorie_juridique },
        company_naf: -> { diagnosis&.facility&.naf_code },
        company_effectif: -> { Effectif::CodeEffectif.new(diagnosis&.facility&.code_effectif).intitule_effectif },
        company_forme_exercice: -> { diagnosis&.company&.forme_exercice&.humanize },
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
