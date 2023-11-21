module Stats::Filters
  class Base
    def initialize(query)
      @query = query
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
