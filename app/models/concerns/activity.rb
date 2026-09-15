# frozen_string_literal: true

module Activity
  def self.default_date_range = (2.years.ago..)

  module User
    extend ActiveSupport::Concern

    included do
      has_many :activity_feedbacks, -> { where(updated_at: Activity.default_date_range) }, class_name: 'Feedback', inverse_of: :user, dependent: :nullify

      scope :with_activity, -> (date_range = Activity.default_date_range) do
        where(id: ::User.joins(:experts).merge(::Expert.with_activity(date_range)))
          .or(where(id: Feedback.where(updated_at: date_range).select(:user_id)))
          .or(where(id: managers))
      end
      scope :without_activity, -> (date_range = Activity.default_date_range) do
        where.not(id: ::User.joins(:experts).merge(::Expert.with_activity(date_range)))
          .where.not(id: Feedback.where(updated_at: date_range).select(:user_id))
          .where.not(id: managers)
      end
    end
  end

  module Expert
    extend ActiveSupport::Concern

    included do
      has_many :activity_matches, -> { with_activity }, class_name: 'Match', inverse_of: :expert, dependent: :nullify

      scope :with_activity, -> (date_range = Activity.default_date_range) { not_deleted.where(id: ::Match.with_activity(date_range).select(:expert_id)) }
      scope :without_activity, -> (date_range = Activity.default_date_range) { not_deleted.where.not(id: ::Match.with_activity(date_range).select(:expert_id)) }
    end
  end

  module Match
    extend ActiveSupport::Concern

    included do
      scope :with_activity, -> (date_range = Activity.default_date_range) do
        where.not(status: :quo).where(updated_at: date_range)
      end
    end
  end
end
