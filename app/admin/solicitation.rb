ActiveAdmin.register Solicitation do
  menu priority: 7

  ## Index
  #
  scope :all, default: true

  index do
    selectable_column
    column :solicitation do |s|
      div admin_link_to(s)
      div admin_attr(s, :email)
      div admin_attr(s, :phone_number)
      div do
        span admin_attr(s, :siret)
        if s.siret.present?
          span ' — '
          span link_to t('active_admin.solicitations.show_company_page'), company_path(s.siret)
        end
      end
      div admin_attr(s, :description).truncate(20000, separator: ' ')
    end
    column :created_at
    column :tracking do |s|
      render 'solicitations/tracking', solicitation: s
    end
    column :slug do |s|
      link_to s.slug, landing_path(s.slug) if s.slug
    end
    column :institution
    actions dropdown: true
  end

  ## CSV
  #
  csv do
    column :email
    column :phone_number
    column :description
    column :created_at
    Solicitation::FORM_INFO_KEYS.each{ |k| column k }
  end

  ## Show
  #
  show do
    attributes_table do
      row :email
      row :phone_number
      row :siret do |s|
        span s.siret
        if s.siret.present?
          span ' — '
          span link_to t('active_admin.solicitations.show_company_page'), company_path(s.siret)
        end
      end
      row :slug do |s|
        link_to s.slug, landing_path(s.slug) if s.slug
      end
      row :description
      row :institution
      row :tracking do |s|
        render 'solicitations/tracking', solicitation: s
      end
      row :created_at
      row :updated_at
    end
  end

  ## Form
  #
  permit_params :description, :email, :phone_number, :siret
  form do |f|
    f.inputs do
      f.input :description
      f.input :siret
      f.input :email
      f.input :phone_number
    end

    f.actions
  end
end
