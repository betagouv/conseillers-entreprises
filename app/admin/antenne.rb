ActiveAdmin.register Antenne do
  menu parent: :experts, priority: 1

  ## Index
  #
  includes :institution, :advisors, :experts, :sent_matches, :received_matches
  config.sort_order = 'name_asc'

  scope :all, default: true
  scope :without_communes

  index do
    selectable_column
    column(:name) do |a|
      div admin_link_to(a)
      div admin_link_to(a, :institution)
    end
    column(:community) do |a|
      div admin_link_to(a, :advisors)
      div admin_link_to(a, :experts)
    end
    column(:intervention_zone) do |a|
      div admin_link_to(a, :territories)
      div admin_link_to(a, :communes)
    end
    column(:activity) do |a|
      div admin_link_to(a, :sent_matches)
      div admin_link_to(a, :received_matches)
    end
  end

  filter :name
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :name
    column :institution
    column_count :advisors
    column_count :experts
    column_count :territories
    column_count :communes
    column_count :sent_matches
    column_count :received_matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :institution
      row(:intervention_zone) do |a|
        div admin_link_to(a, :territories)
        div admin_link_to(a, :communes)
        div intervention_zone_description(a)
      end
      row(:community) do |a|
        div admin_link_to(a, :advisors)
        div admin_link_to(a, :experts)
      end
      row(:activity) do |a|
        div admin_link_to(a, :sent_matches)
        div admin_link_to(a, :received_matches)
      end
    end
  end

  ## Form
  #
  permit_params :name, :institution_id, :insee_codes, :show_icon, advisor_ids: [], expert_ids: []

  form do |f|
    f.inputs do
      f.input :name
      f.input :show_icon
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
        search_fields: [:name]
      }

      f.input :insee_codes, as: :text
    end

    f.inputs do
      f.input :advisors, label: t('attributes.advisors'), as: :ajax_select, data: {
        url: :admin_users_path,
        search_fields: [:full_name],
        limit: 999
      }
    end

    f.inputs do
      f.input :experts, label: t('attributes.experts'), as: :ajax_select, data: {
        url: :admin_experts_path,
        search_fields: [:full_name],
        limit: 999
      }
    end

    f.actions
  end
end
