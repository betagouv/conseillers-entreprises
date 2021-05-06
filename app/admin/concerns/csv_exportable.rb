module CsvExportable
  def self.included(dsl)
    dsl.action_item :export_csv, method: :post do
      ransack_params = params.slice(:q).permit(q: {})[:q]
      path = polymorphic_path([:export_csv, :admin, resource_class.model_name.collection.to_sym], q: ransack_params)
      link_to t('active_admin.csv_export'), path, method: :post
    end

    ## Using `.send` because the ResourceDSL methods are (wrongly) private
    # See https://github.com/activeadmin/activeadmin/issues/3673#issuecomment-291267819
    dsl.send(:collection_action, :export_csv, method: :post) do
      ransack_params = params.slice(:q).permit(q: {})[:q]
      CsvJob.perform_later(resource_class.name, ransack_params, current_user)
      flash.notice = t('active_admin.csv_export_launched')
      redirect_back fallback_location: admin_root_path
    end
  end
end
