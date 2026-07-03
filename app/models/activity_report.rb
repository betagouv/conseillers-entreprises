# == Schema Information
#
# Table name: activity_reports
#
#  id              :bigint(8)        not null, primary key
#  category        :enum
#  end_date        :date
#  reportable_type :string           not null
#  start_date      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reportable_id   :bigint(8)        not null
#
# Indexes
#
#  index_activity_reports_on_category    (category)
#  index_activity_reports_on_reportable  (reportable_type,reportable_id)
#  index_activity_reports_reportable_id  (reportable_id)
#
class ActivityReport < ApplicationRecord
  enum :category, { matches: 'matches', stats: 'stats', cooperation: 'cooperation', solicitations: 'solicitations' }, prefix: true

  belongs_to :reportable, polymorphic: true
  belongs_to :cooperation, -> { where(activity_reports: { reportable_type: 'Cooperation' }) },
             foreign_key: 'reportable_id', inverse_of: :activity_reports, optional: true
  belongs_to :antenne, -> { where(activity_reports: { reportable_type: 'Antenne' }) },
             foreign_key: 'reportable_id', inverse_of: :activity_reports, optional: true

  def cooperation = (reportable if reportable_type == 'Cooperation')

  def antenne = (reportable if reportable_type == 'Antenne')

  has_one_attached :file

  def period
    start_date..end_date
  end

  def period=(range)
    self.start_date = range.begin
    self.end_date = range.end
  end
end
