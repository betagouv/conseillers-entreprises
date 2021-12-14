# frozen_string_literal: true

module UserImpersonate
  class Engine < Rails::Engine
    # Devise user model
    config.user_class = 'User'

    # User model lookup method
    config.user_finder = 'find'

    # User model primary key attribute
    config.user_id_column = 'id'

    # User model name attribute used for search
    # Usage: User.where('#{user_name_column} like ?', '%#{params[:search]}%')
    config.user_name_column = 'full_name'

    # User model staff attribute
    config.user_is_staff_method = 'role_admin?'

    # Redirect to this path when entering impersonate mode
    config.redirect_on_impersonate = '/mon_compte'

    # Redirect to this path when leaving impersonate mode
    config.redirect_on_revert = -> (env) { "/admin/users/#{current_user.id}" }

    # Devise filter method used to protect impersonation controller
    # For Active Admin "AdminUser" model, change to 'authenticate_admin_user!'
    config.authenticate_user_method = 'authenticate_user!'

    # Devise method used to sign user in
    config.sign_in_user_method = 'sign_in'

    # Devise staff user class
    # For Active Admin "AdminUser" model, change to 'AdminUser'
    config.staff_class = 'User'

    # Staff user model lookup method
    config.staff_finder = 'find'

    # Devise method storing current user
    # For Active Admin "AdminUser" model, change to 'current_admin_user'
    config.current_staff = 'current_user'
  end
end
