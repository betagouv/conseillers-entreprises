class ChangeApiCallingUrlToOriginUrl < ActiveRecord::Migration[7.0]
  def change
    up_only do
      # On modifie les solicitations venant de l'API
      Solicitation.where("(form_info->'api_calling_url') is not null").find_each do |solicitation|
        solicitation.origin_url = solicitation.api_calling_url
        solicitation.save!
      end
    end
  end
end
