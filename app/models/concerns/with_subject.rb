module WithSubject
  extend ActiveSupport::Concern

  included do
    scope :ordered_for_interview, -> do
      joins(:subject)
        .merge(Subject.ordered_for_interview)
    end
    scope :available_subjects, -> do
      ordered_for_interview
        .includes(:theme)
        .merge(Subject.archived(false))
    end
    scope :grouped_by_theme, -> do
      group_by { |is| is.theme }
    end
  end
end
