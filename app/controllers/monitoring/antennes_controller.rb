class Monitoring::AntennesController < ApplicationController
  include PersistedSearch

  layout 'side_menu'

  before_action :authenticate_admin!
  before_action -> { redirect_to collection: COLLECTIONS.keys.first }, if: -> { collection_name.blank? }
  before_action :collections_counts

  def search_session_key = :monitoring_antennes_search

  def search_fields = [:region_code, :institution_id]

  COLLECTIONS = %w[often_not_for_me rarely_done rarely_satisfying]
    .index_by{ I18n.t(it, scope: 'monitoring.antennes.path') }
    .freeze
  def index
    @antennes = Antenne
      .public_send(collection_name)
      .apply_filters(index_search_params)
  end

  private

  def collection_name
    @collection_name ||= COLLECTIONS[params[:collection]]
  end

  def collections_counts
    @collections_counts ||=
      {
        often_not_for_me: Antenne.often_not_for_me.size,
        rarely_done: Antenne.rarely_done.size,
        rarely_satisfying: Antenne.rarely_satisfying.size,
      }
  end
end
