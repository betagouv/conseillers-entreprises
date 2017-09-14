# frozen_string_literal: true

module Api
  class ErrorsController < ApplicationController
    class FrontEndError < StandardError
    end

    def create
      error_message = update_params[:name] + ' | ' + update_params[:message]
      stack_array = update_params[:stack].as_json.map(&:to_s)

      error = FrontEndError.new error_message
      error.set_backtrace(stack_array)

      send_error_notifications(error)
    end

    private

    def update_params
      params.require(:error_report).permit(:name, :message, :mode, stack: [%i[url func line column context]])
    end
  end
end
