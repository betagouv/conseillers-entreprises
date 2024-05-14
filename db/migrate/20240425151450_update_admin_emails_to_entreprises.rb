class UpdateAdminEmailsToEntreprises < ActiveRecord::Migration[7.0]
  def change
    User.admin.each do |admin|
      next if admin.id == 18085
      new_email = admin.email.gsub('@beta.gouv.fr', '@entreprises.service-public.fr')
      admin.update(email: new_email)
    end
  end
end
