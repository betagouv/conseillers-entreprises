class Manager::NeedsController < ApplicationController
  include Inbox
  include ManagerFilters
  before_action :authorize_index_needs
  before_action :retrieve_recipient
  before_action :persist_search_params, only: [:index, :quo_active, :taking_care, :done, :not_for_me, :expired]
  before_action only: [:index, :quo_active, :taking_care, :done, :not_for_me, :expired] do
    initialize_filters(all_filter_keys)
  end

  layout 'side_menu'

  def index
    redirect_to action: :quo_active
  end

  def quo_active
    antenne_retrieve_needs(retrieve_recipient, :quo_active, order: :asc)
  end

  def taking_care
    antenne_retrieve_needs(retrieve_recipient, :taking_care)
  end

  def done
    antenne_retrieve_needs(retrieve_recipient, :done)
  end

  def not_for_me
    antenne_retrieve_needs(retrieve_recipient, :not_for_me)
  end

  def expired
    antenne_retrieve_needs(retrieve_recipient, :expired)
  end

  private

  def retrieve_recipient
    @recipient = if params[:antenne_id].present?
      current_user.supervised_antennes.find(params[:antenne_id])
    else
      current_user.managed_antennes.by_higher_territorial_level.first
    end
  end

  def recipient_for_search
    @recipient.is_a?(ActiveRecord::Associations::CollectionProxy) ? @recipient.first : @recipient
  end

  def authorize_index_needs
    authorize :needs, :index?, policy_class: Manager::NeedsPolicy
  end

  # Filtering
  #
  # utilisé pour initialisé les filtres ManagerFilters
  def base_needs_for_filters
    @base_needs_for_filters ||= @recipient.perimeter_received_needs.distinct
  end

  def all_filter_keys
    [:antennes, :themes, :subjects, :cooperations]
  end

  def dynamic_filter_keys
    [:subjects]
  end
end
