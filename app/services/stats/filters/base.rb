module Stats::Filters
  class Base
    # graph_struct is an OpenStruct with the attributes of Stats::BaseStats::FILTER_PARAMS
    def initialize(query, graph_struct)
      @query = query
      @graph_struct = graph_struct
    end

    def call
      territories_filter(@graph_struct.territory)
      antenne_or_institution_filter(@graph_struct.antenne_or_institution, @graph_struct.agglomerate_data)
      subject_filter(@graph_struct.subject)
      integration_filter(@graph_struct.integration)
      iframe_filter(@graph_struct.iframe_id)
      theme_filter(@graph_struct.theme)
      mtm_campaign_filter(@graph_struct.mtm_campaign)
      mtm_kwd_filter(@graph_struct.mtm_kwd)
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
