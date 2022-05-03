class Manager::NeedsController < ApplicationController
  include Inbox
  before_action :retrieve_recipient

  layout 'side_menu'

  def index
    redirect_to action: :quo
  end

  def quo
    antenne_retrieve_needs(retrieve_recipient, :quo)
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
      current_user.managed_antennes.find(params[:antenne_id])
    elsif current_user.managed_antennes.count == 1
      current_user.managed_antennes.first
    else
      current_user.managed_antennes
    end
  end
end
