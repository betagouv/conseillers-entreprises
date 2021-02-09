module RangeScopes
  extend ActiveSupport::Concern

  included do
    scope :created_between, -> (start_date, end_date) {
      where arel_table[:created_at].in(start_date.at_beginning_of_day..end_date.at_end_of_day)
    }
  end
end
