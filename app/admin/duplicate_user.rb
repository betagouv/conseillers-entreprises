ActiveAdmin.register_page 'Duplicate user' do
  belongs_to :user
  Formtastic::FormBuilder.perform_browser_validations = true

  page_action :duplicate, method: :post do
    old_user = User.find(params[:user_id])
    if old_user.deleted?
      flash[:alert] = t('active_admin.duplicate_user.deleted_user')
      redirect_to admin_users_path and return
    end
    user_params = params.require(:user).permit(:full_name, :email, :phone_number, :job)
    new_user = User.duplicate_from(old_user, user_params)
    if new_user.valid?
      message_1 = t('active_admin.duplicate_user.completed', new_user: new_user)
      message_2 = t('active_admin.duplicate_user.completed_reassign_matches', old_user: old_user)
      reassign_path = admin_expert_reassign_matches_path(old_user.single_user_experts.first, selected_expert_id: new_user.single_user_experts.first.id)
      flash[:notice] = "#{message_1} #{helpers.link_to message_2, reassign_path}"
      redirect_to admin_user_path(new_user)
    else
      flash[:alert] = new_user.errors.full_messages.to_sentence
      redirect_to admin_user_duplicate_user_path(old_user)
    end
  end

  content title: I18n.t('active_admin.duplicate_user.title') do
    old_user = User.find(params[:user_id])
    new_user = User.new(job: old_user.job)

    panel t('active_admin.duplicate_user.new_user_details'), class: 'active-admin-form' do
      div class: "information" do
        # single-user expert
        single_user_expert = old_user.single_user_experts.first
        if single_user_expert.present?
          div t('active_admin.duplicate_user.old_user_has_single_expert', user: old_user)
          # territorial zones
          if single_user_expert.territorial_zones.any?
            div t('active_admin.duplicate_user.old_expert_has_territorial_zones')
          end
          # match filters
          if single_user_expert.match_filters.any?
            div t('active_admin.duplicate_user.old_expert_has_match_filters', count: single_user_expert.match_filters.size)
          end
        end
        # teams
        teams = old_user.experts.with_many_users
        if teams.any?
          div t('active_admin.duplicate_user.old_user_has_teams', user: old_user, teams: teams.map(&:to_s).to_sentence, count: teams.size)
        end
        # user rights
        user_rights = old_user.user_rights
        if user_rights.any?
          div t('active_admin.duplicate_user.old_user_has_user_rights', user: old_user, count: user_rights.size)
        end
      end

      table do
        active_admin_form_for new_user, url: admin_user_duplicate_user_duplicate_path do |f|
          f.input :full_name, input_html: { required: true }
          f.input :job
          f.input :email, input_html: { required: true }
          f.input :phone_number
          f.submit t('active_admin.duplicate_user.submit')
        end
      end
    end
  end
end
