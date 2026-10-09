ActiveAdmin.register FileImport do
  menu parent: :experts, priority: 5
  actions :index
  config.filters = false

  controller do
    include ActiveStorage::SetCurrent
  end

  index do
    column :id
    column :institution
    column :author
    column :file do |file_import|
      link_to file_import.file.filename, file_import.file.url
    end
    column :completed?
    column :result_objects do |file_import|
      admin_link_to_collection file_import.result_objects if file_import.result_object_ids.present?
    end
    column :created_at
    column :updated_at
    actions
  end
end
