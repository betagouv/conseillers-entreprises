class Admin::PurgeCsvExportsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    User.admin.with_attached_csv_exports.find_each do |user|
      user.csv_exports.each do |export|
        export.purge_later if export.created_at < 1.week.ago
      end
    end
  end
end
