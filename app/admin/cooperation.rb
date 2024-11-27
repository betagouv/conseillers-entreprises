ActiveAdmin.register Cooperation do
  menu parent: :themes, priority: 4

  # include AdminArchivable

  includes :institution, :cooperation_themes, :landings, :logo

  # controller do
  #   defaults :finder => :find_by_slug!
  # end

  # scope :not_archived, default: true

  # scope :is_archived

  ## Index
  #
  index do
    selectable_column
    column :name do |c|
      admin_link_to c
    end
    column :image, class: 'logo' do |c|
      display_logo(name: c.logo&.filename, path: "cooperations/") if c.logo.present?
    end
    column :institution do |c|
      div admin_link_to c.institution if c.institution.present?
    end
    column(:landings){ |c| admin_link_to(c, :landings, list: true) }
    actions dropdown: true
  end

  filter :name
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :landings, as: :ajax_select, data: { url: :admin_landings_path, search_fields: [:title] }

  ## Show
  #
  show do
    attributes_table do
      # row(:deleted_at) if resource.deleted?
      row :name
      row(:institution) do |c|
        div admin_link_to(c, :institution)
      end
      row(:logo) do |i|
        display_logo(name: i.logo&.filename, path: "cooperations/") if i.logo.present?
      end
      row :url
      row :display_url
      row :mtm_campaign
      row(:landings) do |c|
        div admin_link_to(c, :landings, list: true)
      end
    end
  end

  permit_params :name,
                :logo_id, :mtm_campaign, :url, :display_url,
                :institution_id, landing_ids: []

  form do |f|
    f.inputs do
      f.input :name
      f.input :institution,
        as: :ajax_select,
        data: {
          url: :admin_institutions_path,
          search_fields: [:name]
        }
      f.input :landings,
        as: :ajax_select,
        data: {
          url: :admin_landings_path,
          search_fields: [:slug]
        }

      f.input :url
      f.input :display_url
      f.input :mtm_campaign
    end

    f.actions
  end
end
