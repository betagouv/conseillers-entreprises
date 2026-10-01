module FeatureMacros
  def login_user
    let(:current_user) { create :user }

    before { login_as current_user, scope: :user }
  end

  def login_manager
    let(:current_user) { create :user, :manager }

    before { login_as current_user, scope: :user }
  end

  def login_admin
    let(:current_user) { create :user, :admin }

    before { login_as current_user, scope: :user }
  end
end
