class CreateUserRightsForTerritories < ActiveRecord::Migration[7.2]
  def up
    Territory.where.not(code_region: nil, support_contact_id: nil).find_each do |territory|
      ActiveRecord::Base.transaction do
        user_right = UserRight.new(
          user_id: territory.support_contact_id,
          category: :territorial_referent
        )
        user_right.save!(validate: false)
        region_code = if territory.code_region.to_s.length < 2
          "0#{territory.code_region}"
        else
          territory.code_region
        end

        territorial_zone = TerritorialZone.create!(
          code: region_code,
          zone_type: 'region',
          zoneable_id: user_right.id,
          zoneable_type: 'UserRight'
        )

        # Finally, update the UserRight with the territorial_zone (with validations)
        user_right.update!(rightable_element: territorial_zone)
      end
    end
  end

  def down
    UserRight.where(category: :territorial_referent).find_each do |user_right|
      if user_right.rightable_element.is_a?(TerritorialZone)
        Territory.find_by(code_region: user_right.territorial_zone.code)&.update(support_contact_id: user_right.user_id)
        territorial_zone = TerritorialZone.find_by(
          code: user_right.rightable_element.code,
          zone_type: 'region',
          zoneable_type: 'UserRight'
        )
        territorial_zone&.destroy
      end
      user_right.destroy
    end
  end
end
