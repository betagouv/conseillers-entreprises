module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> (archived) do
      archived = ActiveModel::Type::Boolean.new.cast(archived)
      if archived
        where.not(archived_at: nil)
      else
        where(archived_at: nil)
      end
    end
    scope :not_archived, -> { where(archived_at: nil) }
    scope :is_archived, -> { where.not(archived_at: nil) }

    ransacker(:archived, formatter: -> (value) {
      archived(value).ids.presence
    }) { |parent| parent.table[:id] }
  end

  def archive!
    self.archived_at = Time.zone.now
    self.save!
  end

  def unarchive!
    self.archived_at = nil
    self.save!
  end

  def is_archived
    archived_at.present?
  end

  def not_archived?
    archived_at.blank?
  end
end
