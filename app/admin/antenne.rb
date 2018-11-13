ActiveAdmin.register Antenne do
  menu parent: :experts, priority: 2
  includes :institution, :communes, :experts, :users

  permit_params [
    :name,
    :institution_id,
    :insee_codes,
    user_ids: [],
    expert_ids: [],
  ]

  ## Index
  #

  config.sort_order = 'name_asc'

  index do
    selectable_column
    id_column
    column :name
    column :institution
    column :experts, :experts_count
    column :users, :users_count
    column(:communes) { |a| a.communes.size }
    # The two following lines are actually “N+1 requests” expensive
    # We’ll probably want to remove them or use some counter at some point.
    column(I18n.t('attributes.match_sent.other')) { |a| "#{a.sent_matches.size}" }
    column(I18n.t('attributes.match_received.other')) { |a| "#{a.received_matches.size}" }
  end

  filter :name
  filter :institution_name, as: :string, label: I18n.t('activerecord.models.institution.one')

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :institution
      row :created_at
      row :updated_at
      row(:communes) do |a|
        safe_join(a.communes.map do |commune|
          link_to commune, admin_commune_path(commune)
        end, ', '.html_safe)
      end
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.antenne.users'),
      users: antenne.users
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.antenne.experts'),
      experts: antenne.experts
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.match_sent', count: antenne.sent_matches.size),
      matches: antenne.sent_matches
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.match_received', count: antenne.received_matches.size),
      matches: antenne.received_matches
    }
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
        search_fields: [:name],
        limit: 999,
      }

      f.input :insee_codes
    end

    f.inputs do
      f.input :users, label: t('activerecord.attributes.antenne.users'), as: :ajax_select, data: {
        url: :admin_users_path,
        search_fields: [:full_name],
        limit: 999,
      }
    end

    f.inputs do
      f.input :experts, label: t('activerecord.attributes.antenne.experts'), as: :ajax_select, data: {
        url: :admin_experts_path,
        search_fields: [:full_name],
        limit: 999,
      }
    end

    f.actions
  end
end
