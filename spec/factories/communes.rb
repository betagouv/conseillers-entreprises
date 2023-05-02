FactoryBot.define do
  factory :commune do
    insee_code { Faker::Number.unique.number(digits: 5) }

    trait :geometry do
      after(:create) do |commune, _|
        # Give the commune a square geometry of size 1 by 1 (at x = id so that each commune has its own square)
        sql = <<~SQL.squish
          INSERT INTO "geo_communes_2022" ("code", "wkb_geometry")
            VALUES (:code, 'SRID=4326;POLYGON((:x0 0, :x0 1, :x1 1, :x1 0, :x0 0))')
        SQL
        x0 = commune.id.to_i
        x1 = commune.id.to_i + 1
        sql = ApplicationRecord.sanitize_sql_for_assignment([sql, code: commune.insee_code, x0: x0, x1: x1])
        ApplicationRecord.connection.execute(sql)
      end
    end
  end
end
