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
  permit_params :filename, :name, :logoable_globalid

  form do |f|
    f.inputs do
      f.input :name
      f.input :filename
      all_logoables = [Cooperation.not_archived.order(:name), Institution.not_deleted.order(:name), Landing.not_archived.order(:title)].map do |group|
        items = group.map { [it, it.to_global_id] }
        group_name = group.human_count
        [group_name, items]
      end
      f.input :logoable_globalid, collection: all_logoables
    end
    f.actions
  end
end
