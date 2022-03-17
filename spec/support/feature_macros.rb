# frozen_string_literal: true

module FeatureMacros
  def login_user
    let(:current_user) { create :user }

    before do
      login_as current_user, scope: :user
    end
  end

  def login_admin
    let(:current_user) { create :user, :admin }

    before do
      login_as current_user, scope: :user
    end
  end
end
