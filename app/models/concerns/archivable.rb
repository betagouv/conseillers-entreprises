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

    ransacker(:archived, formatter: -> (value) {
      archived(value).pluck(:id)
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

  def archived?
    archived_at.present?
  end
end
