# frozen_string_literal: true

FactoryBot.define do
  factory :territory do
    name { Faker::Address.country }

    trait :region do
      bassin_emploi { false }
      sequence(:code_region) { |n| "#{n}" }
    end

    trait :geometry do
      after(:create) do |territory, _|
        # Give the territory a square geometry of size 1 by 1 (at x = id so that each territory has its own square)
        sql = <<~SQL.squish
          INSERT INTO "geo_regions_2022" ("code", "wkb_geometry")
            VALUES (:code, 'SRID=4326;POLYGON((:x0 0, :x0 1, :x1 1, :x1 0, :x0 0))')
        SQL
        x0 = territory.id.to_i
        x1 = territory.id.to_i + 1
        sql = ApplicationRecord.sanitize_sql_for_assignment([sql, code: territory.code_region, x0: x0, x1: x1])
        ApplicationRecord.connection.execute(sql)
      end
    end
  end
end
