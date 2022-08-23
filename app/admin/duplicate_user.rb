ActiveAdmin.register_page 'Duplicate user' do
  belongs_to :user
  Formtastic::FormBuilder.perform_browser_validations = true

  page_action :duplicate, method: :post do
    old_user = User.find(params[:user_id])
    user_params = params.require(:user).permit(:full_name, :email, :phone_number, :job, :specifics_territories)
    new_user = old_user.duplicate(user_params)
    if new_user.persisted?
      flash[:notice] = t('active_admin.user.created')
      redirect_to admin_users_path
    else
      flash[:alert] = t('active_admin.user.not_created')
      redirect_to admin_user_duplicate_user_path(old_user)
    end
  end

  content title: I18n.t('active_admin.duplicate_user.title') do
    panel t('active_admin.duplicate_user.new_user_details'), class: 'active-admin-form' do
      table do
        new_user = User.new
        user = User.find(params[:user_id])
        active_admin_form_for new_user, url: admin_user_duplicate_user_duplicate_path do |f|
          f.input :full_name, input_html: { required: true }
          li do
            f.label :job
            f.text_field :job, value: user.job
          end
          f.input :email, input_html: { required: true }
          f.input :phone_number
          if user.experts.map(&:custom_communes?).any?
            f.input :specifics_territories, as: :boolean, label: I18n.t('active_admin.user.duplicate_territories')
          end
          f.submit
        end
      end
    end
  end
end
