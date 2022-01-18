# frozen_string_literal: true

class PartnerToolsController < ApplicationController
  layout 'side_menu'

  def inserts
    @insert = insert_params

    if @insert.present?
      pk_params = insert_params.slice(:pk_campaign, :pk_kwd).compact_blank
      image = "<img src='#{root_url}encarts/#{@insert[:color]}-#{(@insert[:width].to_i * 2)}.png' alt='#{t('.alt')}' width='#{@insert[:width]}'>"
      @insert[:code] = "<a href='#{root_url(pk_params)}' style='text-decoration: none;'>#{image}</a>"
    end
  end

  private

  def insert_params
    params.permit(:pk_campaign, :pk_kwd, :color, :width)
  end
end
