# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonConcern do
  describe 'normalize_name' do
    subject { user.full_name }

    let(:user) { create :user, full_name: name }

    context 'Clean value' do
      let(:name) { 'Paul Mc Cartney' }

      it do
        user.normalize_name
        is_expected.to eq 'Paul Mc Cartney'
      end
    end

    context 'Dirty value' do
      let(:name) { ' paul 		 mcCartney  ' }

      it do
        user.normalize_name
        is_expected.to eq 'Paul Mc Cartney'
      end
    end
  end

  describe 'normalize_phone_number' do
    subject { user.phone_number }

    let(:user) { create :user, phone_number: phone_number }

    context 'Clean value' do
      let(:phone_number) { '01 23 45 67 89' }

      it do
        user.normalize_phone_number
        is_expected.to eq '01 23 45 67 89'
      end
    end

    context 'Dirty value' do
      let(:phone_number) { '0123456789' }

      it do
        user.normalize_phone_number
        is_expected.to eq '01 23 45 67 89'
      end
    end

    context 'Other format' do
      let(:phone_number) { '01 23456789 abcd-12' }

      it do
        user.normalize_phone_number
        is_expected.to eq '01 23456789 abcd-12'
      end
    end
  end

  describe 'normalize_role' do
    subject { user.normalize_role }

    let(:user) { create :user, role: role }

    context 'Clean value' do
      let(:role) { 'Important Job Title' }

      it do
        user.normalize_role
        is_expected.to eq 'Important Job Title'
      end
    end

    context 'Dirty value' do
      let(:role) { ' IMPORTANT  job title		 ' }

      it do
        user.normalize_role
        is_expected.to eq 'Important Job Title'
      end
    end
  end
end
