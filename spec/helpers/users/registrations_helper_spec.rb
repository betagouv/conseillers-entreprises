# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsHelper, type: :helper do
  describe 'new_registration_params' do
    it do
      expected_full_name = 'Juliette'
      params[:full_name] = expected_full_name

      returned_hash = helper.new_registration_params params

      expect(returned_hash[:default_full_name]).to eq expected_full_name
    end
  end
end
