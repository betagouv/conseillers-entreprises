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

  def antenne_retrieve_needs(recipient, collection_name, view = :index)
    @recipient = recipient
    antenne_inbox_collections_counts(@recipient)
    @collection_name = collection_name

    @needs = if recipient.is_a?(Antenne)
      Need.in_antennes_perimeters(@recipient).merge!(@recipient.send("needs_#{@collection_name}"))
    else
      Need.in_antennes_perimeters(@recipient).merge!(Need.where(id: @recipient.collect { |a| a.send("needs_#{@collection_name}") }.flatten))
    end
    @needs = @needs.includes(:company, :advisor, :subject)
      .order(created_at: :desc)
      .page params[:page]
    render view
  end

  def inbox_collections_counts(recipient)
    @inbox_collections_counts = Rails.cache.fetch([recipient.received_needs, recipient.received_needs.pluck(:updated_at).max]) do
      inbox_collection_names.index_with { |name| recipient.send("needs_#{name}").distinct.size }
    end
  end

  def antenne_inbox_collections_counts(recipient)
    if recipient.is_a?(Antenne)
      @inbox_collections_counts = Rails.cache.fetch([Need.in_antenne_perimeters(recipient), Need.in_antenne_perimeters(recipient).pluck(:updated_at).max]) do
        inbox_collection_names.index_with do |name|
          Need.in_antenne_perimeters(recipient).merge!(recipient.send("needs_#{name}")).distinct.size
        end
      end
    else
      @inbox_collections_counts = Rails.cache.fetch([Need.in_antennes_perimeters(recipient), Need.in_antennes_perimeters(recipient).pluck(:updated_at).max]) do
        inbox_collection_names.index_with do |name|
          Need.in_antennes_perimeters(recipient).merge!(Need.where(id: recipient.collect { |a| a.send("needs_#{name}") }.flatten)).size
        end
      end
    end
  end
end
