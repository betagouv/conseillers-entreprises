# frozen_string_literal: true

module FeatureMacros
  def login_user
    let(:current_user) { create :user }

    before do
      login_as current_user, scope: :user
    end
  end
end
