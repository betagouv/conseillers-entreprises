# == Schema Information
#
# Table name: activity_reports
#
#  id              :bigint(8)        not null, primary key
#  category        :enum
#  end_date        :date
#  reportable_type :string
#  start_date      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reportable_id   :bigint(8)
#
# Indexes
#
#  index_activity_reports_on_category    (category)
#  index_activity_reports_on_reportable  (reportable_type,reportable_id)
#
class ActivityReport < ApplicationRecord
  enum :category, { matches: 'matches', stats: 'stats', cooperation: 'cooperation', solicitations: 'solicitations' }, prefix: true

  belongs_to :reportable, polymorphic: true
  belongs_to :cooperation, -> { where(activity_reports: { reportable_type: 'Cooperation' }) },
             foreign_key: 'reportable_id', inverse_of: :activity_reports, optional: true
  belongs_to :antenne, -> { where(activity_reports: { reportable_type: 'Antenne' }) },
             foreign_key: 'reportable_id', inverse_of: :activity_reports, optional: true

  has_one_attached :file
end
