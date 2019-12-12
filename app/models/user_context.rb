class UserContext
  attr_reader :user, :expert

  def initialize(user, expert)
    @user = user
    @expert = expert
  end
end
