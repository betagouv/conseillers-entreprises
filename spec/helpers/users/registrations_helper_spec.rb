# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsHelper, type: :helper do
  describe 'form_default_values_for_resource' do
    it do
      resource = create :user
      expected_full_name = 'Juliette'
      params[:default_full_name] = expected_full_name

      helper.form_default_values_for_resource resource

      expect(resource.full_name).to eq expected_full_name
    end
  end

  describe 'new_registration_params' do
    it do
      expected_full_name = 'Juliette'
      params[:full_name] = expected_full_name

      returned_hash = helper.new_registration_params params

      expect(returned_hash[:default_full_name]).to eq expected_full_name
    end
  end
end
