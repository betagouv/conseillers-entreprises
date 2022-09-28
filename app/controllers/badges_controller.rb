# frozen_string_literal: true

class BadgesController < ApplicationController
  before_action :find_badge, only: [:destroy, :edit, :update]
  layout 'side_menu'

  def index
    redirect_to action: :solicitations
  end

  def solicitations
    @badges = Badge.category_solicitations
    render :index
  end

  def needs
    @badges = Badge.category_needs
    render :index
  end

  def new
    @badge = Badge.new
  end

  def create
    @badge = Badge.create(safe_params)
    if @badge.persisted?
      flash.notice = t('.badge_created')
      redirect_to badges_path
    else
      flash.alert = @badge.errors.full_messages.to_sentence
      render 'shared/flashes'
    end
  end

  def destroy
    @badge.destroy
    flash.notice = t('.badge_destroyed')
    redirect_to badges_path
  end

  def edit; end

  def update
    if @badge.update(safe_params)
      flash.notice = t('.badge_updated')
      redirect_to action: @badge.category
    else
      render edit
    end
  end

  private

  def safe_params
    params.require(:badge).permit(:title, :color, :category)
  end

  def find_badge
    @badge = Badge.find(params[:id])
  end
end
