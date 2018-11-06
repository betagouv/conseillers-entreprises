# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 1
  permit_params [
    :name,
    :qualified_for_commerce,
    :qualified_for_artisanry,
    antenne_ids: []
  ]

  ## Index
  #
  filter :experts, collection: -> { Expert.ordered_by_names }
  filter :name
  filter :created_at
  filter :updated_at
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
      end
    end
  end

  action_item :convert_to_antenne, only: :show do
    link_to t('active_admin.antenne.create_antenne'), convert_to_antenne_admin_institution_path(resource)
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

  ## Actions
  #
  member_action :convert_to_antenne do
    antenne = Antenne.create_from_institution!(resource)
    redirect_to admin_antenne_path(antenne)
  end

  batch_action I18n.t('active_admin.antenne.create_antenne') do |ids|
    batch_action_collection.find(ids).each { |institution| Antenne.create_from_institution!(institution) }
    redirect_to admin_antennes_path, notice: I18n.t('active_admin.antenne.antennes_created')
  end
end
