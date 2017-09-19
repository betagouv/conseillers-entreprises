# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'some routes of application', type: :routing do
  it do
    expect(get '/experts/diagnoses/32').to route_to(controller: 'experts', action: 'diagnosis', diagnosis_id: '32')
  end
end
