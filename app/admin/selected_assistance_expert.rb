# frozen_string_literal: true

ActiveAdmin.register SelectedAssistanceExpert do
  menu parent: :diagnoses, priority: 2
  actions :index, :show, :edit, :update
  permit_params :diagnosed_need_id, :assistances_experts_id, :territory_user_id, :status
  includes diagnosed_need: [diagnosis: [visit: :advisor]]

  index do
    selectable_column
    id_column
    column('Date de contact', :created_at)
    column :diagnosed_need
    column('Conseiller') { |sae| sae.diagnosed_need.diagnosis&.visit&.advisor&.full_name }
    column :expert_full_name
    column :expert_institution_name
    column :assistance_title
    column :expert_viewed_page_at
    column(:status) { |sae| t("activerecord.attributes.selected_assistance_expert.statuses.#{sae.status}") }
    column('Page Référent') do |sae|
      diagnosis_id = sae.diagnosed_need.diagnosis_id
      if sae.assistance_expert
        access_token = sae.assistance_expert.expert.access_token
        link_to 'Page Référent', diagnosis_experts_path(diagnosis_id: diagnosis_id, access_token: access_token)
      else
        link_to 'Page Référent',
                diagnosis_territory_users_path(diagnosis_id: diagnosis_id, territory_user_id: sae.territory_user_id)
      end
    end

    actions
  end

  form do |f|
    f.inputs do
      f.input :diagnosed_need, collection: (DiagnosedNeed.order(diagnosis_id: :desc).map do |dn|
        ["Analyse #{dn.diagnosis_id}, Besoin #{dn.question_id} (#{dn.question})", dn.id]
      end)
      f.input :assistance_expert, collection: (AssistanceExpert.order(expert_id: :desc).map do |ae|
        assistance_title = truncate(ae.assistance&.title, length: 40)
        ["#{ae.expert&.full_name}, Champ de compétence #{ae.assistance_id} (#{assistance_title})", ae.id]
      end)
      f.input :territory_user, collection: TerritoryUser.all.map { |tu| [tu.user.full_name, tu.id] }
      f.input :status
    end

    f.actions
  end

  filter :diagnosed_need, collection: -> { DiagnosedNeed.order(created_at: :desc).pluck(:id) }
  filter :expert_full_name
  filter :expert_institution_name
  filter :assistance_title
  filter :status
  filter :created_at
  filter :updated_at

  controller do
    def update
      super
      if territory_user_changed?
        fill_from_territory_user
      end

      if assistance_expert_changed?
        fill_from_assistance_expert
      end
    end

    def territory_user_changed?
      form_param = params[:selected_assistance_expert]
      form_param[:territory_user_id].present? && form_param[:territory_user_id] != resource.territory_user_id
    end

    def fill_from_territory_user
      territory_user = TerritoryUser.find params[:selected_assistance_expert][:territory_user_id]
      resource.update expert_full_name: territory_user.user.full_name,
                      expert_institution_name: territory_user.user.institution,
                      assistance_title: nil
    end

    def assistance_expert_changed?
      form_param = params[:selected_assistance_expert]
      form_param[:assistances_experts_id].present? &&
        form_param[:assistances_experts_id] != resource.assistances_experts_id
    end

    def fill_from_assistance_expert
      assistance_expert = AssistanceExpert.find params[:selected_assistance_expert][:assistances_experts_id]
      resource.update expert_full_name: assistance_expert.expert&.full_name,
                      expert_institution_name: assistance_expert.expert&.institution&.name,
                      assistance_title: assistance_expert.assistance&.title
    end
  end
end
