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
      path = l.logoable_type == 'Cooperation' ? "cooperations/" : "institutions/"
      display_logo(name: l.filename, path: path)
    end
    column :logoable
    actions dropdown: true
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :filename
      row :logoable
      row :image, class: 'logo' do |l|
        path = l.logoable_type == 'Cooperation' ? "cooperations/" : "institutions/"
        display_logo(name: l.filename, path: path)
      end
    end
  end

  ## Form
  #
  permit_params :filename, :name, :logoable_id, :logoable_type

  form do |f|
    f.inputs do
      f.input :name
      f.input :filename
    end
    f.actions
  end
end
