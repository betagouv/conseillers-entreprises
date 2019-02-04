module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where.not(archived_at: nil) }
    scope :not_archived, -> { where(archived_at: nil) }
  end

  def archive!
    self.archived_at = Time.zone.now
    self.save!
  end

  def unarchive!
    self.archived_at = nil
    self.save!
  end

  def archived?
    archived_at.present?
  end
end
