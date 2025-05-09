SELECT
  needs.id AS need_id, 
  (
    to_tsvector('simple', unaccent(coalesce((needs.content)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((subjects.label)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((facilities.readable_locality)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((companies.name)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((companies.siren)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((contacts.full_name)::text, ''))) ||
    to_tsvector('simple', unaccent(coalesce((contacts.email)::text, '')))
  ) AS tsv_document
FROM needs
JOIN subjects ON subjects.id = needs.subject_id
JOIN diagnoses ON diagnoses.id = needs.diagnosis_id 
INNER JOIN facilities ON facilities.id = diagnoses.facility_id
INNER JOIN companies ON companies.id = facilities.company_id
INNER JOIN contacts ON contacts.id = diagnoses.visitee_id
