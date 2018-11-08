# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 1
  permit_params [
    :name,
    :qualified_for_commerce,
    :qualified_for_artisanry,
    antenne_ids: []
  ]

  includes :antennes, :experts

  ## Index
  #
  filter :name
  filter :qualified_for_commerce
  filter :qualified_for_artisanry

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end

    panel I18n.t('activerecord.attributes.institution.antennes') do
      table_for institution.antennes do
        column(I18n.t('activerecord.attributes.antenne.name')) { |antenne| link_to(antenne, admin_antenne_path(antenne)) }
        column(I18n.t('activerecord.attributes.antenne.experts')) do |antenne|
          safe_join(antenne.experts.map { |expert| link_to(expert, admin_expert_path(expert)) }, ', '.html_safe)
        end
      end
    end
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :qualified_for_commerce
      f.input :qualified_for_artisanry
    end
    f.inputs do
      f.input :antennes, label: t('activerecord.attributes.institution.antennes'), as: :ajax_select, data: {
        url: :admin_antennes_path,
        search_fields: [:name],
        limit: 999,
      }
    end

    f.actions
  end
end
