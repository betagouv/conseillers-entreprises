namespace :fixup_updated_at do
  def disable_timestamps
    # Prevent (more) accidental timestamp updates
    # (we’re using update_column, so this is actually unneeded, but it’s a good policy nonetheless.)
    before_value = ActiveRecord::Base.record_timestamps
    ActiveRecord::Base.record_timestamps = false
    yield
    ActiveRecord::Base.record_timestamps = before_value
  end

  # For #676 we accidentaly touched all the matches.
  # migrate_skills_to_instituion.rake was run on Thu, 28 Nov 2019 17:50.
  # In match, :updated_at is always the max of :created_at, :taken_care_of_at, :closed_at
  task accidentally_touched_matches: :environment do
    disable_timestamps do
      matches_accidentaly_touched = Match.where("updated_at > closed_at")
        .or(Match.where(closed_at: nil).where('updated_at > taken_care_of_at'))

      matches_accidentaly_touched.find_each do |match|
        match.update_column(:updated_at, [match.created_at, match.taken_care_of_at, match.closed_at].compact.max)
      end
    end
  end

  # For #926 and #1038 we accidentaly touched all feedbacks.
  # AddFeedbackableToFeedbacks was run on Tue, 21 Apr 2020 14:45.
  # expert_to_user_for_feedbacks.rake was run on Thu, 30 Apr 2020 16:41.
  # In feedback, updated_at is always :created_at
  task accidentally_touched_feedbacks: :environment do
    disable_timestamps do
      feedbacks_accidentaly_touched = Feedback.where("updated_at > created_at")

      feedbacks_accidentaly_touched.find_each do |feedback|
        feedback.update_column(:updated_at, feedback.created_at)
      end
    end
  end

  # We recently added touch: true to relations:
  # Match#belongs_to :need
  # Feedback#belongs_to :need (feedbackable)
  task touch_needs: :environment do
    disable_timestamps do
      needs = Need.left_outer_joins(:matches, :feedbacks)
        .group('needs.id')
        .select('needs.*',
                'max(matches.updated_at) as max_matches_updated_at',
                'max(feedbacks.updated_at) as max_feedbacks_updated_at')

      needs.find_each do |need|
        max_updated_at = [
          need.updated_at,
          need.max_matches_updated_at,
          need.max_feedbacks_updated_at
        ].compact.max
        need.update_column(:updated_at, max_updated_at)
      end
    end
  end

  # We recently added touch: true to relations:
  # Need#belongs_to :diagnosis
  task touch_diagnoses: :environment do
    disable_timestamps do
      diagnoses = Diagnosis.left_outer_joins(:needs)
        .group('diagnoses.id')
        .select('diagnoses.*',
                'max(needs.updated_at) as max_needs_updated_at')

      diagnoses.find_each do |diagnosis|
        max_updated_at = [
          diagnosis.updated_at,
          diagnosis.max_needs_updated_at
        ].compact.max
        diagnosis.update_column(:updated_at, max_updated_at)
      end
    end
  end

  # We recently added touch: true to relations:
  # Feedback#belongs_to :solicitation (feedbackable)
  # Diagnosis#belongs_to :solicitation
  task touch_solicitations: :environment do
    disable_timestamps do
      solicitations = Solicitation.left_outer_joins(:diagnoses, :feedbacks)
        .group('solicitations.id')
        .select('solicitations.*',
                'max(diagnoses.updated_at) as max_diagnoses_updated_at',
                'max(feedbacks.updated_at) as max_feedbacks_updated_at')

      solicitations.find_each do |solicitation|
        max_updated_at = [
          solicitation.updated_at,
          solicitation.max_diagnoses_updated_at,
          solicitation.max_feedbacks_updated_at
        ].compact.max
        solicitation.update_column(:updated_at, max_updated_at)
      end
    end
  end

  desc 'Fix accidentally touched matches and feedbacks in previous data migration tasks'
  task accidental_touches: %i[accidentally_touched_matches accidentally_touched_feedbacks]

  desc 'Fix need, diagnoses and solicitations that may have been created before we added the touch: true flags.'
  task created_before_touch_flag: %i[touch_needs touch_diagnoses touch_solicitations]
  task all: %i[accidental_touches accidentally_touched_feedbacks]
end

desc 'Fixup accidentally touched updated_at fields in DB'
task fixup_updated_at: %w[fixup_updated_at:all]
