module AdminArchivable
  def self.included(dsl)
    ## Actions
    #
    ## Using `.send` because the ResourceDSL methods are (wrongly) private
    # See https://github.com/activeadmin/activeadmin/issues/3673#issuecomment-291267819
    dsl.send(:member_action, :archive) do
      resource.archive!
      redirect_back fallback_location: collection_path, notice: t('archivable.archive_done')
    end

    dsl.send(:member_action, :unarchive) do
      resource.unarchive!
      redirect_back fallback_location: collection_path, notice: t('archivable.unarchive_done')
    end

    dsl.action_item(:archive, only: :show, if: -> { !resource.archived? }) do
      link_to t('archivable.archive'), polymorphic_path([:archive, :admin, resource])
    end

    dsl.action_item(:unarchive, only: :show, if: -> { resource.archived? }) do
      link_to t('archivable.unarchive'), polymorphic_path([:unarchive, :admin, resource])
    end

    dsl.batch_action(I18n.t('archivable.archive')) do |ids|
      batch_action_collection.find(ids).each do |resource|
        resource.archive!
      end
      redirect_back fallback_location: collection_path, notice: I18n.t('archivable.archive_done')
    end

    dsl.batch_action(I18n.t('archivable.unarchive')) do |ids|
      batch_action_collection.find(ids).each do |resource|
        resource.unarchive!
      end
      redirect_back fallback_location: collection_path, notice: I18n.t('archivable.unarchive_done')
    end
  end

  ::ActiveAdmin::Views::IndexAsTable::IndexTableFor.module_eval do
    def index_row_archive_actions(resource)
      if resource.archived?
        item t('archivable.unarchive'), polymorphic_path([:unarchive, :admin, resource])
      else
        item t('archivable.archive'), polymorphic_path([:archive, :admin, resource])
      end
    end
  end
end
