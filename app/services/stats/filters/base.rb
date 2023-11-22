module Stats::Filters
  class Base
    def initialize(query)
      @query = query
    end

    def call
      territories_filter(@territory)
      antenne_or_institution_filter(@antenne_or_institution)
      subject_filter(@subject)
      integration_filter(@integration)
      iframe_filter(@iframe_id)
      theme_filter(@theme)
      mtm_campaign_filter(@mtm_campaign)
      mtm_kwd_filter(@mtm_kwd)
      @query
    end

    def antenne_or_institution
      antenne.presence || institution.presence
    end

    def pk_campaign_query
      "solicitations.form_info::json->>'pk_campaign' ILIKE ?"
    end

    def mtm_campaign_query
      "solicitations.form_info::json->>'mtm_campaign' ILIKE ?"
    end

    def pk_kwd_query
      "solicitations.form_info::json->>'pk_kwd' ILIKE ?"
    end

    def mtm_kwd_query
      "solicitations.form_info::json->>'mtm_kwd' ILIKE ?"
    end
  end
end
