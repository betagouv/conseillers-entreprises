# frozen_string_literal: true

ActiveAdmin.register Company do
  menu priority: 9

  ## Index
  #
  includes :facilities, :contacts, :diagnoses, :needs, :matches
  config.sort_order = 'created_at_desc'

  scope :all, default: true

  index do
    selectable_column
    column(:name) do |c|
      div admin_link_to(c)
      div admin_attr(c, :siren)
      div admin_attr(c, :legal_form_code), title: c.categorie_juridique
      if c.code_effectif?
        div admin_attr(c, :code_effectif), title: c.intitule_effectif
      end
      if c.forme_exercice?
        div admin_attr(c, :forme_exercice), title: c.forme_exercice
      end
    end
    column :created_at
    column(:facilities) do |c|
      div admin_link_to(c, :facilities)
      div admin_link_to(c, :contacts)
    end
    column(:activity) do |c|
      div admin_link_to(c, :diagnoses, blank_if_empty: true)
      div admin_link_to(c, :needs, blank_if_empty: true)
      div admin_link_to(c, :matches, blank_if_empty: true)
    end
    actions dropdown: true
  end

  filter :name
  filter :siren
  filter :legal_form_code
  filter :facilities_naf_code, as: :string
  filter :code_effectif
  filter :facilities_regions, collection: -> { Territory.regions.order(:name) }
  filter :created_at

  ## CSV
  #
  csv do
    column :name
    column :siren
    column :legal_form_code
    column :code_effectif
    column :created_at
    column_count :facilities
    column_list :contacts
    column_count :diagnoses
    column_count :needs
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :siren
      row :legal_form_code do |c|
        [c.legal_form_code, c.categorie_juridique].join(' - ')
      end
      row :code_effectif
      row :created_at
      row(:facilities) do |c|
        div admin_link_to(c, :facilities)
        div admin_link_to(c, :contacts)
      end
      row(:activity) do |c|
        div admin_link_to(c, :diagnoses)
        div admin_link_to(c, :needs)
        div admin_link_to(c, :matches)
      end
    end
  end

  ## Form
  #
  permit_params :name, :siren, :legal_form_code, :code_effectif
end
