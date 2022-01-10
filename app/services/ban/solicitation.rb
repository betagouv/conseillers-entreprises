class Ban::Solicitation
  attr_reader :solicitation

  def initialize(solicitation)
    @solicitation = solicitation
  end

  def toggle
    if solicitation.banned? || solicitation.from_banned_company?
      unban
    else
      ban
    end
  end

  def ban
    solicitation.update(banned: true)
    Solicitation.from_same_company(solicitation).update_all(banned: true)
  end

  def unban
    solicitation.update(banned: false)
    Solicitation.from_same_company(solicitation).update_all(banned: false)
  end
end
