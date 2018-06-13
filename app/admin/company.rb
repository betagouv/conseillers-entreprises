# frozen_string_literal: true

ActiveAdmin.register Company do
  menu priority: 4
  permit_params :name, :siren

  filter :name
  filter :siren
  filter :legal_form_code
  filter :created_at
  filter :updated_at

  show do
    default_main_content

    panel I18n.t('activerecord.attributes.company.facilities') do
      table_for company.facilities do
        column :siret
        column :city_code
        column :naf_code
        column :readable_locality
      end
    end
  end

end
