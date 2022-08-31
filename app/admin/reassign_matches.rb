ActiveAdmin.register_page 'Reassign matches' do
  belongs_to :user
  Formtastic::FormBuilder.perform_browser_validations = true

  page_action :reassign, method: :post do
    old_user = User.find(params[:user_id])
    selected_user = User.find(params[:selected_user_id])
    begin
      result = old_user.transfer_in_progress_matches(selected_user)
      flash[:notice] = t('active_admin.user.reassign_matches_done', count: result.count, user: selected_user)
      redirect_to admin_user_path(old_user)
    rescue StandardError => e
      flash[:alert] = I18n.t('activerecord.attributes.user.errors.cant_transfer_match', error: e.message)
      redirect_to admin_user_reassign_matches_path(old_user)
    end
  end

  content title: I18n.t('active_admin.reassign_matches.title') do
    render partial: "reassign_matches", locals: { user: User.find(params[:user_id]) }
  end
end
