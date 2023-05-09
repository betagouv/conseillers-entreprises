module Inbox
  extend ActiveSupport::Concern

  included do
    helper_method :needs_search_params
  end

  private

  def inbox_collection_names
    %i[quo_active taking_care done not_for_me expired]
  end

  # Common render method for collection actions
  def retrieve_needs(recipient, collection_name, view: :index, order: :desc)
    @recipient = recipient
    inbox_collections_counts(recipient)
    @collection_name = collection_name

    @needs = recipient
      .send("needs_#{collection_name}") # See InvolvementConcern
      .includes(:company, :advisor, :subject, :solicitation, :facility)
      .order(created_at: order)
      .apply_filters(needs_search_params)
      .page params[:page]
    render view
  end

  def antenne_retrieve_needs(recipient, collection_name, view: :index, order: :desc)
    @recipient = recipient
    antenne_inbox_collections_counts(@recipient)
    @collection_name = collection_name

    @needs = if recipient.is_a?(Antenne)
      @recipient.perimeter_received_needs.merge!(@recipient.send("territory_needs_#{@collection_name}"))
    else
      Need.in_antennes_perimeters(@recipient).merge!(Need.where(id: @recipient.map { |a| a.send("territory_needs_#{@collection_name}") }.flatten))
    end
    @needs = @needs.includes(:company, :advisor, :subject)
      .order(created_at: order)
      .page params[:page]
    render view
  end

  def inbox_collections_counts(recipient)
    @inbox_collections_counts = inbox_collection_names.index_with { |name| recipient.send("needs_#{name}").distinct.size }
  end

  def antenne_inbox_collections_counts(recipient)
    @inbox_collections_counts = if recipient.is_a?(Antenne)
      inbox_collection_names.index_with do |name|
        recipient.perimeter_received_needs.merge!(recipient.send("territory_needs_#{name}")).distinct.size
      end
    else
      inbox_collection_names.index_with do |name|
        Need.in_antennes_perimeters(recipient).merge!(Need.where(id: recipient.map { |a| a.send("territory_needs_#{name}") }.flatten)).size
      end
    end
  end

  def needs_search_params
    session[:needs_search_params]&.with_indifferent_access || {}
  end

  def persist_search_params
    session[:needs_search_params] ||= {}
    search_params = params.slice(:omnisearch, :by_subject, :created_since, :created_until).permit!
    if params[:reset_query].present?
      session.delete(:needs_search_params)
    else
      session[:needs_search_params] = session[:needs_search_params].merge(search_params)
    end
  end
end
