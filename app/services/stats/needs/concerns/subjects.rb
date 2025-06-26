module Stats::Needs::Concerns::Subjects
  include Stats::Needs::Base

  def main_query
    needs_subjects_base_scope
      .joins(:advisor)
      .joins(:subject)
  end

  def needs_subjects_base_scope
    needs_base_scope
  end

  def date_group_attribute
    :created_at
  end

  def category_group_attribute
    'subject.label'
  end

  def category_order_attribute
    'subject.interview_sort_order'
  end

  def build_series
    result = super
    result.reject { |item| item[:data].all?(0) }
  end

  def filtered(query)
    Stats::Filters::Needs.new(query, self).call
  end

  def count
    false
  end

  def colors
    %w[#62e0d3 #2D908F #f3dd68 #e78112 #F45A5B #9f3cca #F15C80 #A8FF96 #946c47 #64609b #7a7a7a #CF162B]
  end
end
