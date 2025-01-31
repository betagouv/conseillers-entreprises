class SharedSatisfactionPolicy < ApplicationPolicy
  def show_navbar?
    Institution.expert_provider.include?(@user.institution)
  end
end
