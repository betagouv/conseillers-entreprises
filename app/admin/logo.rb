ActiveAdmin.register Logo do
  menu parent: :experts, priority: 3
  config.sort_order = "filename_asc"

  ## Index
  #
  index do
    selectable_column
    column :name do |l|
      admin_link_to l
    end
    column :filename
    column :image, class: 'logo' do |l|
      display_image(name: l.filename, path: "institutions/")
    end
    column :institution
    actions dropdown: true
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :filename
      row :institution
      row :image, class: 'logo' do |l|
        display_image(name: l.filename, path: "institutions/")
      end
    end
  end

  ## Form
  #
  permit_params :filename, :name, :institution_id

  form do |f|
    f.inputs do
      f.input :name
      f.input :filename, input_html: { disabled: true }
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
        search_fields: [:name]
      }
    end
    f.actions
  end
end
