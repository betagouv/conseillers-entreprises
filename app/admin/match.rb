# frozen_string_literal: true

ActiveAdmin.register Match do
  menu parent: :diagnoses, priority: 2
  actions :index, :show, :edit, :update
  permit_params :diagnosed_need_id, :assistances_experts_id, :relay_id, :status
  includes diagnosed_need: [diagnosis: [visit: :advisor]]

  index do
    selectable_column
    id_column
    column('Date de contact', :created_at)
    column :diagnosed_need
    column('Conseiller') { |match| match.diagnosed_need.diagnosis&.visit&.advisor&.full_name }
    column :expert_full_name
    column :expert_institution_name
    column :assistance_title
    column :expert_viewed_page_at
    column(:status) { |match| t("activerecord.attributes.match.statuses.#{match.status}") }
    column('Page Référent') do |match|
      diagnosis_id = match.diagnosed_need.diagnosis_id
      if match.assistance_expert
        access_token = match.assistance_expert.expert.access_token
        link_to 'Page Référent', diagnosis_experts_path(diagnosis_id: diagnosis_id, access_token: access_token)
      else
        link_to 'Page Référent',
                diagnosis_relays_path(diagnosis_id: diagnosis_id, relay_id: match.relay_id)
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
      f.input :relay, collection: Relay.all.map { |relay| [relay.user.full_name, relay.id] }
      f.input :status
    end

    f.actions
  end

  filter :territories, collection: -> { Territory.order(:name) }
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
      if relay_changed?
        fill_from_relay
      end

      if assistance_expert_changed?
        fill_from_assistance_expert
      end
    end

    def relay_changed?
      form_param = params[:match]
      form_param[:relay_id].present? && form_param[:relay_id] != resource.relay_id
    end

    def fill_from_relay
      relay = Relay.find params[:match][:relay_id]
      resource.update expert_full_name: relay.user.full_name,
                      expert_institution_name: relay.user.institution,
                      assistance_title: nil
    end

    def assistance_expert_changed?
      form_param = params[:match]
      form_param[:assistances_experts_id].present? &&
        form_param[:assistances_experts_id] != resource.assistances_experts_id
    end

    def fill_from_assistance_expert
      assistance_expert = AssistanceExpert.find params[:match][:assistances_experts_id]
      resource.update expert_full_name: assistance_expert.expert&.full_name,
                      expert_institution_name: assistance_expert.expert&.institution&.name,
                      assistance_title: assistance_expert.assistance&.title
    end
  end
end
