# frozen_string_literal: true

ActiveAdmin.register Match do
  menu parent: :diagnoses, priority: 2

  ## Index
  #
  includes :diagnosed_need, :diagnosis, :facility, :company, :related_matches,
    :advisor, :advisor_antenne, :expert, :expert_antenne, :relay_user,
    diagnosed_need: :question

  index do
    selectable_column
    column :match, sortable: :status do |m|
      div admin_link_to(m)
      css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[m.status.to_sym]
      status_tag m.status_short_description, class: css_class
    end
    column :diagnosed_need, sortable: :created_at do |m|
      div admin_link_to(m, :diagnosed_need)
      div I18n.l(m.created_at, format: '%Y-%m-%d %H:%M')
      css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[m.diagnosed_need.status_synthesis.to_sym]
      status_tag m.diagnosed_need.status_short_description, class: css_class
    end
    column :advisor do |m|
      div admin_link_to(m, :advisor)
      div admin_link_to(m, :advisor_antenne)
    end
    column :contacted_expert do |m|
      if m.expert.present?
        div admin_link_to(m, :expert)
        div admin_link_to(m, :expert_antenne)
        div link_to('Page Référent', besoin_path(m.diagnosis, access_token: m.expert.access_token))
      elsif m.relay_user.present?
        div admin_link_to(m, :relay_user)
        div link_to(t('active_admin.user.impersonate', name: m.relay_user.full_name), impersonate_engine.impersonate_user_path(m.relay_user))
      else
        div I18n.t('active_admin.matches.deleted', expert: m.expert_description)
      end
    end

    actions dropdown: true
  end

  filter :status

  filter :created_at

  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :advisor_antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :advisor_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }

  filter :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :expert_antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :expert_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }

  filter :assistance, as: :ajax_select, data: { url: :admin_assistances_path, search_fields: [:title] }

  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :id
    column(:status) { |m| m.status_short_description }
    column :facility
    column(:diagnosed_need) { |m| m.diagnosed_need_id }
    column(:question) { |m| m.diagnosed_need.question }
    column :created_at
    column(:status_description) { |m| m.diagnosed_need.status_short_description }
    column :advisor
    column :advisor_antenne
    column :advisor_institution
    column :expert
    column :expert_antenne
    column :expert_institution
    column('Page Référent') { |m| besoin_url(m.diagnosis, access_token: m.expert.access_token) if m.expert.present? }
    column :relay_user
  end

  ## Show
  #
  show do
    attributes_table do
      row :status do |m|
        css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[m.status.to_sym]
        status_tag m.status_description, class: css_class
      end
      row :diagnosed_need
      row :created_at
      row :status_synthesis do |m|
        css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[m.diagnosed_need.status_synthesis.to_sym]
        status_tag m.diagnosed_need.status_description, class: css_class
      end
      row :advisor
      row :advisor_antenne
      row :contacted_expert do |m|
        if m.expert.present?
          div admin_link_to(m, :expert)
          div admin_link_to(m, :expert_antenne)
          div link_to('Page Référent', besoin_path(m.diagnosis, access_token: m.expert.access_token))
        elsif m.relay_user.present?
          div admin_link_to(m, :relay_user)
          div link_to(t('active_admin.user.impersonate', name: m.relay_user.full_name), impersonate_engine.impersonate_user_path(m.relay_user))
        else
          div I18n.t('active_admin.matches.deleted', expert: m.expert_description)
        end
      end
    end
  end

  ## Form
  #
  permit_params :diagnosed_need_id, :assistances_experts_id, :relay_id, :status
  form do |f|
    f.inputs do
      f.input :status
    end

    f.actions
  end
end
