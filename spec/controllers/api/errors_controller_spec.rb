# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ErrorsController, type: :controller do
  login_user

  describe 'POST #create' do
    params = {
      'errorReport' => {
        'mode' => 'stack',
        'name' => 'ReferenceError',
        'message' => 'blabla is not defined',
        'stack' => [
          {
            'url' => 'webpack-internal:///421',
            'func' => 'Store.getDiagnosisContentValue',
            'args' => [],
            'line' => 42,
            'column' => 9,
            'context' => nil
          },
          {
            'url' => 'webpack-internal:///25',
            'func' => 'Array.wrappedActionHandler',
            'args' => [],
            'line' => 668,
            'column' => 23,
            'context' => nil
          }
        ],
        'incomplete' => true
      }
    }
    expected_backtrace_array = [
      '{"url"=>"webpack-internal:///421", "func"=>"Store.getDiagnosisContentValue",' \
      ' "line"=>"42", "column"=>"9", "context"=>""}',
      '{"url"=>"webpack-internal:///25", "func"=>"Array.wrappedActionHandler",' \
      ' "line"=>"668", "column"=>"23", "context"=>""}'
    ]

    before do
      allow(controller).to receive(:send_error_notifications)
      post :create, format: :json, params: params
    end

    it 'succeeds' do
      expect(response).to have_http_status(:no_content)
    end

    it 'calls send_error_notifications with a configured error' do
      expected_error = Api::ErrorsController::FrontEndError.new 'ReferenceError | blabla is not defined'
      expected_error.set_backtrace(expected_backtrace_array)
      expect(controller).to have_received(:send_error_notifications).with(expected_error)
    end
  end
end
