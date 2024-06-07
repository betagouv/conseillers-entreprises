## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)
* ➡ [Gotchas & tips (fr)](05-gotchas.md)
* [Maintenance (fr)](06-maintenance.md)

# onseillers-Entreprises - Gotchas & Tips

## Problème de génération des reports

```ruby 
a = Antenne.find(:id)

a.quarterly_reports.all.each do |qr|
  qr.file.purge
end

a.quarterly_reports.destroy_all

QuarterlyReports::GenerateReports.new(a).call
```

En cas de `PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_active_storage_blobs_on_key" (ActiveRecord::RecordNotUnique)`

Trouver les blobs qui on une clé qui contient le nom d'une antenne et les supprimer :

```ruby 
blobs = ActiveStorage::Blob.where("key LIKE '%pole-emploi-94-choisy-le-roi%'")
blobs.first.attachments.destroy_all
```

Puis relancer la génération des rapports.
