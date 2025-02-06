# == Schema Information
#
# Table name: need_omnisearches
#
#  tsv_document :tsvector
#  need_id      :bigint(8)        primary key
#
# Indexes
#
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

  # pg_search_scope :omnisearch,
  #                 against: [:content],
  #                 associated_against: {
  #                   visitee: [:full_name, :email],
  #                   company: [:name, :siren],
  #                   facility: :readable_locality,
  #                   subject: :label
  #                 },
  #                 using: { tsearch: { prefix: true } },
  #                 ignoring: :accents
end
