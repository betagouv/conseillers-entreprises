SELECT
  needs.id AS need_id, 
  (
    to_tsvector('simple', unaccent(coalesce((needs.content)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((subjects.label)::text, '')))
  ) AS tsv_document
FROM needs
JOIN subjects ON subjects.id = needs.subject_id



-- SELECT "needs"."id" AS pg_search_id, (
--       ts_rank((
--         to_tsvector('simple', unaccent(coalesce(("needs"."content")::text, ''))) || 
--         to_tsvector('simple', unaccent(coalesce((pg_search_494d24c1a9beb1d8e6b4b3.pg_search_ed8dc47054d1e6d31010d1)::text, ''))) || 
--         to_tsvector('simple', unaccent(coalesce((pg_search_494d24c1a9beb1d8e6b4b3.pg_search_92086b0aa3ccd60968fbd8)::text, ''))) || 
--         to_tsvector('simple', unaccent(coalesce((pg_search_70802142d8a2acc990bd88.pg_search_ec314d2e365ec97b0a4160)::text, ''))) || 
--         to_tsvector('simple', unaccent(coalesce((pg_search_70802142d8a2acc990bd88.pg_search_6726fc8027f40badcdf781)::text, ''))) || 
--         to_tsvector('simple', unaccent(coalesce((pg_search_867ecf45510664bbb368dc.pg_search_38fa5739bafa415fc2289c)::text, ''))) || 
--         to_tsvector('simple', unaccent(coalesce((pg_search_28c82e8dc93bdf5313b92b.pg_search_d3d680e076bc1b30107182)::text, '')))
--       ), 
--       (to_tsquery('simple', ''' ' || unaccent('Claire') || ' ''' || ':*')), 0)) 
--     AS rank 
--     FROM "needs" LEFT OUTER JOIN (
--       SELECT "needs"."id" AS id, 
--       "contacts"."full_name"::text AS pg_search_ed8dc47054d1e6d31010d1, 
--       "contacts"."email"::text AS pg_search_92086b0aa3ccd60968fbd8 
--       FROM "needs" INNER JOIN "diagnoses" ON "diagnoses"."id" = "needs"."diagnosis_id" INNER JOIN "contacts" ON "contacts"."id" = "diagnoses"."visitee_id"
--     ) pg_search_494d24c1a9beb1d8e6b4b3 ON pg_search_494d24c1a9beb1d8e6b4b3.id = "needs"."id" LEFT OUTER JOIN (
--       SELECT "needs"."id" AS id, 
--       "companies"."name"::text AS pg_search_ec314d2e365ec97b0a4160, 
--       "companies"."siren"::text AS pg_search_6726fc8027f40badcdf781 
--       FROM "needs" INNER JOIN "diagnoses" ON "diagnoses"."id" = "needs"."diagnosis_id" INNER JOIN "facilities" ON "facilities"."id" = "diagnoses"."facility_id" INNER JOIN "companies" ON "companies"."id" = "facilities"."company_id"
--     ) pg_search_70802142d8a2acc990bd88 ON pg_search_70802142d8a2acc990bd88.id = "needs"."id" LEFT OUTER JOIN (
--       SELECT "needs"."id" AS id, 
--       "facilities"."readable_locality"::text AS pg_search_38fa5739bafa415fc2289c 
--       FROM "needs" INNER JOIN "diagnoses" ON "diagnoses"."id" = "needs"."diagnosis_id" INNER JOIN "facilities" ON "facilities"."id" = "diagnoses"."facility_id"
--     ) pg_search_867ecf45510664bbb368dc ON pg_search_867ecf45510664bbb368dc.id = "needs"."id" LEFT OUTER JOIN (
--       SELECT "needs"."id" AS id, 
--       "subjects"."label"::text AS pg_search_d3d680e076bc1b30107182 
--       FROM "needs" INNER JOIN "subjects" ON "subjects"."id" = "needs"."subject_id"
--     ) pg_search_28c82e8dc93bdf5313b92b ON pg_search_28c82e8dc93bdf5313b92b.id = "needs"."id" WHERE ((
--       to_tsvector('simple', unaccent(coalesce(("needs"."content")::text, ''))) || 
--       to_tsvector('simple', unaccent(coalesce((pg_search_494d24c1a9beb1d8e6b4b3.pg_search_ed8dc47054d1e6d31010d1)::text, ''))) || 
--       to_tsvector('simple', unaccent(coalesce((pg_search_494d24c1a9beb1d8e6b4b3.pg_search_92086b0aa3ccd60968fbd8)::text, ''))) || 
--       to_tsvector('simple', unaccent(coalesce((pg_search_70802142d8a2acc990bd88.pg_search_ec314d2e365ec97b0a4160)::text, ''))) || 
--       to_tsvector('simple', unaccent(coalesce((pg_search_70802142d8a2acc990bd88.pg_search_6726fc8027f40badcdf781)::text, ''))) || 
--       to_tsvector('simple', unaccent(coalesce((pg_search_867ecf45510664bbb368dc.pg_search_38fa5739bafa415fc2289c)::text, ''))) || 
--       to_tsvector('simple', unaccent(coalesce((pg_search_28c82e8dc93bdf5313b92b.pg_search_d3d680e076bc1b30107182)::text, '')))
--     ) @@ (
--       to_tsquery('simple', ''' ' || unaccent('Claire') || ' ''' || ':*')))
--     ) AS pg_search_266d1c70a4cbe7cdb557b6 ON "needs"."id" = pg_search_266d1c70a4cbe7cdb557b6.pg_search_id 
