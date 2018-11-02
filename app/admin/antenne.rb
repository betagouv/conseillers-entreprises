ActiveAdmin.register Antenne do
  menu parent: :experts, priority: 3
  includes :institution, :communes, :experts, :users

  ## Index
  #
  index do
    selectable_column
    id_column
    column :name
    column :institution
    column(:communes) { |a| a.communes.size }
    column(:experts) { |a| a.experts.size }
    column(:users) { |a| a.users.size }
  end

  filter :name
  filter :institution
  filter :institution_name

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
      row(:communes) do |a|
        safe_join(a.communes.map do |commune|
          link_to commune, admin_commune_path(commune)
        end, ', '.html_safe)
      end
    end

    panel I18n.t('activerecord.models.expert.other') do
      table_for antenne.experts do
        column(:full_name) { |e| link_to(e, admin_expert_path(e)) }
        column :email
        column :phone_number
        column(:assistances) { |e| e.assistances.size }
      end
    end

    panel I18n.t('activerecord.models.user.other') do
      table_for antenne.users do
        column(:full_name) { |u| link_to(u, admin_user_path(u)) }
        column :email
        column :phone_number
      end
    end

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('activerecord.attributes.match.sent', count: antenne.sent_matches.size),
      matches_relation: antenne.sent_matches
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('activerecord.attributes.match.received', count: antenne.received_matches.size),
      matches_relation: antenne.received_matches
    }
  end
end
