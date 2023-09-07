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
      .apply_filters(needs_search_params)
      .order(created_at: order)
      .page params[:page]
    render view
  end

  def inbox_collections_counts(recipient)
    @inbox_collections_counts = if recipient.is_a? Expert
      inbox_collections_request = Need.joins(:matches).where(archived_at: nil)
        .where(matches: { expert_id: recipient.id, archived_at: nil })
        .where.not(matches: { sent_at: nil })
        .select("
          COUNT(DISTINCT needs.id) FILTER(WHERE matches.status = 'quo' AND matches.created_at >= '#{Need::REMINDERS_DAYS[:abandon]&.days&.ago}') AS quo_active,
          COUNT(DISTINCT needs.id) FILTER(WHERE matches.status = 'taking_care') AS taking_care,
          COUNT(DISTINCT needs.id) FILTER(WHERE matches.status IN ('done', 'done_no_help', 'done_not_reachable')) AS done,
          COUNT(DISTINCT needs.id) FILTER(WHERE matches.status = 'not_for_me') AS not_for_me,
          COUNT(DISTINCT needs.id) FILTER(WHERE matches.status = 'quo' AND matches.created_at <= '#{Need::REMINDERS_DAYS[:abandon]&.days&.ago}') AS expired
        ")
        .to_sql
      results = ActiveRecord::Base.connection.execute(inbox_collections_request)
      results.first.symbolize_keys
    else
      inbox_collection_names.index_with { |name| recipient.send("needs_#{name}").distinct.size }
    end
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
    search_params = params.slice(:omnisearch, :by_subject, :created_since, :created_until, :antenne_id).permit!
    if params[:reset_query].present?
      session.delete(:needs_search_params)
    else
      session[:needs_search_params] = session[:needs_search_params].merge(search_params)
    end
  end

  def possible_themes_subjects_collection(collection_name)
    # Build a hash with themes and subjects covered by recipient_for_search with a counter for needs in current collection
    # Example: { themes: [theme1, theme2], subjects: { subject1.id => 'subject1 (2)', subject2.id => 'subject2 (1)' } }
    hash = { themes: recipient_for_search.themes.ordered_for_interview.uniq, subjects: [] }
    hash[:themes].each do |theme|
      theme.subjects_ordered_for_interview.each do |subject|
        count = recipient_for_search.send("needs_#{collection_name}").where(subject: subject).size
        hash[:subjects][subject.id] = "#{subject.label} (#{count.positive? ? count : '-'})"
      end
    end
    hash
  end
end
