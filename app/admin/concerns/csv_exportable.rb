module CsvExportable
  def self.included(dsl)
    dsl.action_item :export_csv, method: :post do
      path = polymorphic_path([:export_csv, :admin, resource_class.model_name.collection])
      link_to t('active_admin.cvs_export'), path, method: :post
    end

    ## Using `.send` because the ResourceDSL methods are (wrongly) private
    # See https://github.com/activeadmin/activeadmin/issues/3673#issuecomment-291267819
    dsl.send(:collection_action, :export_csv, method: :post) do
      CsvJob.perform_later(resource_class.model_name.name, current_user)
    end
  end
end
