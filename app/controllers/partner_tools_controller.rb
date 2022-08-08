# frozen_string_literal: true

class PartnerToolsController < ApplicationController
  layout 'side_menu'

  def inserts
    @insert = insert_params

    if @insert.present?
      mtm_params = insert_params.slice(:mtm_campaign, :mtm_kwd).compact_blank
      image = "<img src='#{root_url}encarts/#{@insert[:color]}-#{(@insert[:width].to_i * 2)}.png' alt='#{t('.alt')}' width='#{@insert[:width]}'>"
      @insert[:code] = "<a href='#{root_url(mtm_params)}' style='text-decoration: none;'>#{image}</a>"
    end
  end

  private

  def insert_params
    params.permit(:mtm_campaign, :mtm_kwd, :color, :width)
  end
end
