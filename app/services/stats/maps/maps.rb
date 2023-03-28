module Stats::Maps
  class Maps
    # Things go here.

    INCLUDED_INSTITUTIONS = %w[cci cma banque_de_france urssaf dgfip dreets pole-emploi carsat aract initiative-france].freeze
    EXCLUDED_THEMES = %w[Général Support Brexit]
    INCLUDED_STATUS = %w[done done_no_help done_not_reachable not_for_me]
    INCLUDED_USER_ROLES = %[]
    INCLUDED_NEEDS_DATE_RANGE = Date.new(2022,01,01)...Date.new(2023,01,01)

    def self.included_institutions = Institution.where(slug: INCLUDED_INSTITUTIONS) # 10 out of 47 active
    def self.included_antennes = Antenne.where.not(territorial_level: :national) # 1651 out of 2290
    def self.included_themes = Theme.where.not(label: EXCLUDED_THEMES)
    def self.included_subjects = Subject.joins(:theme).merge(included_themes)
    def self.included_users = User.not_deleted.where.missing(:user_rights)

    def self.included_needs
      # 16710 out of 44287
      Need
        .joins(:subject).merge(included_subjects)
        .joins(:matches).where(matches: { taken_care_of_at: INCLUDED_NEEDS_DATE_RANGE })
        .where(status: INCLUDED_STATUS)
    end

    def self.needs_by_code_region # this takes 30-40 seconds
      Territory.joins(communes: [antennes: [:institution, experts: [received_matches: :need]]])
        .merge(included_institutions)
        .merge(included_antennes)
        .merge(included_needs)
        .group('"territories"."id"')
        .select('"territories"."code_region"',
                '"territories"."name"',
                'count(DISTINCT "needs"."id") AS "needs_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'done\') AS "needs_done_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'done_no_help\') AS "needs_done_no_help_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'done_not_reachable\') AS "needs_done_not_reachable_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'not_for_me\') AS "needs_not_for_me_count"',)
    end

    def self.users_by_code_region # this takes 3-5 seconds
      Territory.joins(communes: [antennes: [:institution, experts: :users]])
        .merge(included_institutions)
        .merge(included_antennes)
        .merge(included_users)
        .group('"territories"."id"')
        .select('"territories"."code_region"',
                '"territories"."name"',
                'count(DISTINCT "users"."id") AS "users"')
    end

    def self.users_by_antenne(institution)
      institution.antennes
        .joins(experts: :users)
        .merge(included_antennes)
        .merge(included_users)
        .group('"antennes"."id"')
        .select('"antennes"."id"',
                '"antennes"."name"',
                'count(DISTINCT "users"."id") AS "users"')
    end

    def self.needs_by_antenne(institution)
      institution.antennes
        .joins(experts: [received_matches: :need])
        .merge(included_antennes)
        .merge(included_needs)
        .group('"antennes"."id"')
        .select('"antennes"."id"',
                '"antennes"."name"',
                'count(DISTINCT "needs"."id") AS "needs_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'done\') AS "needs_done_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'done_no_help\') AS "needs_done_no_help_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'done_not_reachable\') AS "needs_done_not_reachable_count"',
                'count(DISTINCT "needs"."id") FILTER (WHERE "needs"."status" = \'not_for_me\') AS "needs_not_for_me_count"',)
    end

    # Institutions / antennes_count
    # We want stats by Antenne (and not by Region) for only a subset of these institutions.
    # Maybe just ANACT, CARSAT, URSSAF make sense
    # We also mentioned CCI.
    # Initiative France: 172
    # Pôle emploi: 679
    # Direction régionale de l’économie, de l’emploi, du travail et des solidarités (DREETS): 115
    # Agence nationale pour l'amélioration des conditions de travail (Anact): 18
    # Chambre de commerce et d'industrie (CCI): 111
    # Direction générale des finances publiques (DGFIP): 101
    # Caisse d'assurance retraite et de la santé au travail (Carsat): 8
    # Chambre de métiers et de l’artisanat (CMA): 142
    # Union de recouvrement des cotisations de Sécurité sociale et d'allocations familiales (Urssaf): 23
    # Banque de France: 111

    def self.institutions_antennes_communes(slug)
      Institution.where(slug: slug).joins(antennes: :communes).select('"institutions"."slug"', '"antennes"."name"', '"communes"."insee_code"').to_sql
    end
  end
end
