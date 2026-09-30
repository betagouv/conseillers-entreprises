module ControllerMacros
  def login_user
    let(:current_user) { create :user }

    setup_devise_mapping_for_controllers

    before { sign_in current_user }
  end

  def login_manager
    let(:current_user) { create :user, :manager }

    setup_devise_mapping_for_controllers

    before { sign_in current_user }
  end

  def login_admin
    let(:current_user) { create :user, :admin }

    setup_devise_mapping_for_controllers

    before { sign_in current_user }
  end

  def setup_devise_mapping_for_controllers
    before { @request.env['devise.mapping'] = Devise.mappings[:user] }
  end

  def mock_landing_themes
    # Mock footer_landing to avoid SharedController errors
    before { allow(controller).to receive(:fetch_themes).and_return(nil) }
  end
end
