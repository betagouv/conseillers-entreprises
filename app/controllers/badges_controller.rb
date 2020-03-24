# frozen_string_literal: true

class BadgesController < ApplicationController
  def index
    @badges = Badge.all
    @badge = Badge.new
  end

  def create
    @badge = Badge.create(safe_params)
    if @badge.persisted?
      redirect_to badges_path
    else
      flash.alert = @badge.errors.full_messages.to_sentence
      render 'shared/flashes'
    end
  end

  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy
    redirect_to badges_path
  end

  private

  def safe_params
    params.require(:badge).permit(:title, :color)
  end
end
