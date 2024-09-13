class DisplayPartnerUrlOnLandings < ActiveRecord::Migration[7.0]
  def change
    add_column :landings, :display_partner_url, :boolean, default: false

    up_only do
      Landing.where(slug: ['entreprendre-service-public-fr', 'team-rh-occitanie', 'cci-les-aides-fr', 'transition-ecologique-entreprises-api', 'zetwal', 'espace-fournisseurs']).find_each do |landing|
        landing.update_attribute(:display_partner_url, true)
      end
    end
  end
end
