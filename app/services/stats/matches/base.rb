module Stats::Matches::Base
  include Stats::Needs::Base

  def matches_base_scope
    Match.sent.joins(:need).where(need: needs_base_scope)
  end

  # Matches are grouped by their need's creation month.
  def month_group_table(_query)
    'needs'
  end

  def colors
    matches_colors
  end

  def main_query
    matches_base_scope
  end

  def filtered_main_query
    Stats::Filters::Matches.new(main_query, self).call
  end
end
