module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :deleted, -> { where.not(deleted_at: nil) }
    scope :not_deleted, -> { where(deleted_at: nil) }
  end

  def deleted?
    deleted_at.present?
  end

  def delete
    update_columns(deleted_at: Time.zone.now)
  end

  def destroy
    # Don’t run callbacks for :destroy (i.e. don't nullify dependent relations.)
    delete
  end
end
