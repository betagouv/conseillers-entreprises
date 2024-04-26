class CreateNationalReferent < ActiveRecord::Migration[7.0]
  def change
    User.where(id: [126, 789, 3174]).find_each do |user|
      user.user_rights.create(category: :national_referent)
    end
  end
end
