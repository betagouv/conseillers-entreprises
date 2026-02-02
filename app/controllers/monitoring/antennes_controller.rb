class Monitoring::AntennesController < ApplicationController
  include PersistedSearch

  layout 'side_menu'

  before_action :authenticate_admin!
  before_action -> { redirect_to collection: COLLECTIONS.first }, if: -> { collection_name.blank? }
  before_action :collections_counts

  def search_session_key = :monitoring_antennes_search

  def search_fields = [:region_code, :institution_id]

  COLLECTIONS = %w[often_rejecting rarely_taking_care rarely_satisfying].freeze
  def index
    @antennes = Antenne
      .public_send(collection_name)
      .apply_filters(index_search_params)
      .page(params[:page])
      .order(collection_attributes(collection_name)[:rate])
  end

  private

  def collection_name
    @collection_name ||= params[:collection] if COLLECTIONS.include?(params[:collection])
  end

  def collections_counts
    @collections_counts ||=
      {
        often_rejecting: Antenne.often_rejecting.size,
        rarely_taking_care: Antenne.rarely_taking_care.size,
        rarely_satisfying: Antenne.rarely_satisfying.size,
      }
  end

  def collection_attributes(collection_name)
    {
      often_rejecting: { rate: :rejecting_rate, count: :rejecting_count },
      rarely_taking_care: { rate: :taking_care_rate, count: :taking_care_count },
      rarely_satisfying: { rate: :satisfying_rate, count: :satisfying_count },
    }[collection_name.to_sym]
  end
  helper_method :collection_attributes
end
