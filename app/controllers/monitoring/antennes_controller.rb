class Monitoring::AntennesController < ApplicationController
  include PersistedSearch

  layout 'side_menu'

  before_action :authenticate_admin!
  before_action -> { redirect_to collection: COLLECTIONS.first }, if: -> { collection_name.blank? }
  before_action :collections_counts

  def search_session_key = :monitoring_antennes_search

  def search_fields = [:region_code, :institution_id]

  COLLECTIONS = %w[often_not_for_me rarely_done rarely_satisfying].freeze
  def index
    @antennes = Antenne
      .public_send(collection_name)
      .apply_filters(index_search_params)
      .page(params[:page])
      .order(collection_attributes(collection_name)[:order])
  end

  private

  def collection_name
    @collection_name ||= params[:collection] if COLLECTIONS.include?(params[:collection])
  end

  def collections_counts
    @collections_counts ||=
      {
        often_not_for_me: Antenne.often_not_for_me.size,
        rarely_done: Antenne.rarely_done.size,
        rarely_satisfying: Antenne.rarely_satisfying.size,
      }
  end

  def collection_attributes(collection_name)
    {
      often_not_for_me: { rate: :not_for_me_rate, count: :not_for_me_count, order: {not_for_me_rate: :desc} },
      rarely_done: { rate: :done_rate, count: :done_count, order: {done_rate: :asc} },
      rarely_satisfying: { rate: :satisfying_rate, count: :satisfying_count, order: {satisfying_rate: :asc} },
    }[collection_name.to_sym]
  end
  helper_method :collection_attributes
end
