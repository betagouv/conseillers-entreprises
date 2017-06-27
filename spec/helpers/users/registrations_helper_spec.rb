# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsHelper, type: :helper do
  describe 'form_default_values_for_resource' do
    it do
      resource = create :user
      expected_first_name = 'Juliette'
      params[:default_first_name] = expected_first_name

      helper.form_default_values_for_resource resource

      expect(resource.first_name).to eq expected_first_name
    end
  end

  describe 'new_registration_params' do
    it do
      expected_first_name = 'Juliette'
      params[:first_name] = expected_first_name

      returned_hash = helper.new_registration_params params

      expect(returned_hash[:default_first_name]).to eq expected_first_name
    end
  end
end
