class AddPolymorphicToBadges < ActiveRecord::Migration[7.0]
  def up
    create_table "badge_badgeables", force: :cascade do |t|
      t.bigint "badgeable_id", null: false
      t.string "badgeable_type", null: false
      t.references :badge, foreign_key: true
      t.timestamps null: false
    end

    up_only do
      solicitations = Solicitation.joins(:badges)
      solicitations.each do |solicitation|
        solicitation.old_badges.each do |badge|
          BadgeBadgeable.create!(badge: badge, badgeable: solicitation)
        end
      end
    end

    drop_table :badges_solicitations
  end

  def down
    create_table "badges_solicitations", id: false, force: :cascade do |t|
      t.bigint "badge_id", null: false
      t.bigint "solicitation_id", null: false
    end

    BadgeBadgeable.find_each do |bb|
      next if bb.badgeable_type != 'Solicitation'
      s = Solicitation.find('badgeable_id')
      s.badges << Badge.find(bb.badge_id)
    end

    drop_table :badge_badgeables
  end
end
