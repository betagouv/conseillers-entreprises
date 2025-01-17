module Inbox
  extend ActiveSupport::Concern

  included do
    helper_method :needs_search_params
    helper_method :possible_themes_subjects_collection
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
      .send(:"needs_#{collection_name}") # See InvolvementConcern
      .includes(:company, :advisor, :subject, :solicitation, :facility)
      .order(created_at: order)
      .apply_filters(needs_search_params)
      .page params[:page]
    render view
  end

  def antenne_retrieve_needs(antenne, collection_name, view: :index, order: :desc)
    @recipient = antenne
    antenne_inbox_collections_counts(@recipient)
    @collection_name = collection_name

    @needs = @recipient.perimeter_received_needs.merge!(@recipient.send(:"territory_needs_#{@collection_name}"))

    # on reject antenne_id, sinon le filtre by_antenne peut venir enlever des besoins
    # (cas des antennes régionales)
    @needs = @needs.includes(:company, :advisor, :subject)
      .apply_filters(needs_search_params.except(:antenne_id))
      .order(created_at: order)
      .page params[:page]
    render view
  end

  def inbox_collections_counts(recipient)
    @inbox_collections_counts = inbox_collection_names.index_with { |name| recipient.send(:"needs_#{name}").distinct.size }
  end

  def antenne_inbox_collections_counts(recipient)
    @inbox_collections_counts = if recipient.is_a?(Antenne)
      inbox_collection_names.index_with do |name|
        recipient.perimeter_received_needs.merge!(recipient.send(:"territory_needs_#{name}")).distinct.size
      end
    else
      inbox_collection_names.index_with do |name|
        Need.in_antennes_perimeters(recipient).merge!(Need.where(id: recipient.map { |a| a.send(:"territory_needs_#{name}") }.flatten)).size
      end
    end
  end

  def needs_search_params
    session[:needs_search_params]&.with_indifferent_access || {}
  end

  def persist_search_params
    session[:needs_search_params] ||= {}
    search_params = params.slice(:omnisearch, :by_subject, :created_since, :created_until, :antenne_id).permit!
    if params[:reset_query].present?
      session.delete(:needs_search_params)
    else
      session[:needs_search_params] = session[:needs_search_params].merge(search_params)
    end
  end

  def possible_themes_subjects_collection
    # Build a hash with themes and subjects covered by recipient_for_search
    hash = { themes: recipient_for_search.themes.ordered_for_interview.uniq, subjects: [] }
    hash[:themes].each do |theme|
      theme.subjects_ordered_for_interview.each do |subject|
        hash[:subjects][subject.id] = subject.label
      end
    end
    hash
  end
end
