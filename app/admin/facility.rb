ActiveAdmin.register Facility do
  menu parent: :companies, priority: 1

  ## Index
  #
  includes :company, :commune, :diagnoses, :needs, :matches
  config.sort_order = 'created_at_desc'

  scope :all, default: true

  index do
    selectable_column
    column(:facility) do |f|
      div admin_link_to(f)
      div admin_attr(f, :siret)
      div admin_attr(f, :naf_code)
      if f.nafa_codes.any?
        div admin_attr(f, :nafa_codes)
      end
      if f.code_effectif?
        div admin_attr(f, :code_effectif), title: f.intitule_effectif
      end
    end
    column(:natures) do |f|
      if f.company.forme_exercice?
        div admin_attr(f.company, :forme_exercice), title: f.company.forme_exercice
      end
      if f.nature_activites.any?
        div admin_attr(f, :nature_activites)
      end
    end

    column :created_at
    column(:activity) do |f|
      div admin_link_to(f, :diagnoses, blank_if_empty: true)
      div admin_link_to(f, :needs, blank_if_empty: true)
      div admin_link_to(f, :matches, blank_if_empty: true)
    end
    actions dropdown: true
  end

  filter :siret
  filter :company_legal_form_code, as: :string
  filter :naf_code
  filter :code_effectif
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :commune_insee_code, as: :string
  filter :regions, collection: -> { Territory.regions.order(:name) }
  filter :created_at

  ## Index
  #
  csv do
    column :company
    column :commune
    column :readable_locality
    column :siret
    column :naf_code
    column :code_effectif
    column :created_at
    column_count :diagnoses
    column_count :needs
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :siret
      row :naf_code
      row :nafa_codes
      row :code_effectif
      row(:company) do |f|
        div admin_link_to(f, :company)
        if f.company.forme_exercice?
          div admin_attr(f.company, :forme_exercice), title: f.company.forme_exercice
        end
      end
      row :nature_activites
      row :commune
      row :readable_locality
      row :created_at
      row(:activity) do |f|
        div admin_link_to(f, :diagnoses)
        div admin_link_to(f, :needs)
        div admin_link_to(f, :matches)
      end
    end
  end

  ## Form
  #
  permit_params :siret, :naf_code, :code_effectif, :company_id, :commune_id, :readable_locality

  form do |f|
    f.inputs do
      f.input :siret
      f.input :naf_code
      f.input :code_effectif
      f.input :company, as: :ajax_select, data: {
        url: :admin_companies_path,
        search_fields: [:name]
      }
      f.input :commune, as: :ajax_select, data: {
        url: :admin_communes_path,
        search_fields: [:insee_code]
      }
      f.input :readable_locality
    end

    actions
  end
end
