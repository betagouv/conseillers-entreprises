module Stats::Matches::Base
  include Stats::Needs::Base

  def matches_base_scope
    Match.sent.joins(:need).where(need: needs_base_scope)
  end

  def filtered(query)
    Stats::Filters::Matches.new(query, self).call
  end

  def get_month_query(query, range)
    query.joins(:need).merge(Need.created_between(range.first, range.last))
  end

  def colors
    matches_colors
  end
end
