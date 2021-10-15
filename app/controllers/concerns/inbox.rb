module Inbox
  extend ActiveSupport::Concern

  private

  def inbox_collection_names
    %i[quo taking_care done not_for_me expired]
  end

  # Common render method for collection actions
  def retrieve_needs(recipient, collection_name, view = :index)
    @recipient = recipient
    inbox_collections_counts(recipient)
    @collection_name = collection_name

    @needs = recipient
      .send("needs_#{collection_name}") # See InvolvementConcern
      .includes(:company, :advisor, :subject)
      .order(created_at: :desc)
      .page params[:page]
    render view
  end

  def inbox_collections_counts(recipient)
    @inbox_collections_counts = Rails.cache.fetch([recipient.received_needs, recipient.received_needs.pluck(:updated_at).max]) do
      inbox_collection_names.index_with { |name| recipient.send("needs_#{name}").distinct.size }
    end
  end
end
