# == Schema Information
#
# Table name: need_omnisearches
#
#  tsv_document :tsvector
#  need_id      :bigint(8)        primary key
#
# Indexes
#
#  index_need_omnisearches_on_need_id       (need_id) UNIQUE
#  index_need_omnisearches_on_tsv_document  (tsv_document) USING gin
#
class NeedOmnisearch < ApplicationRecord
  self.primary_key = :need_id

  include PgSearch::Model

  pg_search_scope :search,
                  against: :tsv_document,
                  using: {
                    tsearch: {
                      prefix: true,
                      tsvector_column: 'tsv_document',
                    }
                  },
                  ignoring: :accents

  def self.refresh_materialized_view
    Scenic.database.refresh_materialized_view(
      :need_omnisearches,
      concurrently: true,
    )
  end
end
