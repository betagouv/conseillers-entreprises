module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :deleted, -> { where.not(deleted_at: nil) }
    scope :not_deleted, -> { where(deleted_at: nil) }
    # scope used for Active Admin translation
    scope :active, -> { not_deleted }
  end

  def deleted?
    deleted_at.present?
  end

  def soft_delete
    update_columns(deleted_at: Time.zone.now)
  end

  def destroy
    # Don’t run callbacks for :destroy (i.e. don't nullify dependent relations.)
    soft_delete
  end

  module ActiveAdminResourceController
    # Override methods from ActiveAdmin::ResourceController::DataAccess

    def find_resource
      # … however, if accessing directly the object, we like to see it even if it is soft-deleted.
      resource_class.all.send method_for_find, params[:id]
    end
  end
end
