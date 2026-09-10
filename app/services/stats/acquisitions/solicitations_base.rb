module Stats::Acquisitions::SolicitationsBase
  include ::Stats::BaseStats
  include Stats::Acquisitions::Base

  def main_query
    Solicitation.step_complete.where(created_at: @start_date..@end_date)
  end

  def filtered(query)
    Stats::Filters::Solicitations.new(query, self).call
  end
end
